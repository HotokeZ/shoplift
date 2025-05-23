import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_modal.dart';
import '../services/auth_service.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Add these new variables
  String? _selectedRole;
  String? _selectedBanStatus;

  // Add these getter methods for filter options
  List<String> get _roleOptions => ['All Roles', 'buyer', 'seller', 'admin'];
  List<String> get _banStatusOptions => ['All Status', 'Banned', 'Active'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _banUser(BuildContext context, String userId) async {
    // First check if user is admin
    final userDoc =
        await FirebaseFirestore.instance
            .collection('accounts')
            .doc(userId)
            .get();

    if (userDoc.data()?['role'] == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Administrators cannot be banned'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Initialize ban status if it doesn't exist
    if (!userDoc.exists || !userDoc.data()!.containsKey('isBanned')) {
      await FirebaseFirestore.instance.collection('accounts').doc(userId).set({
        'isBanned': false,
      }, SetOptions(merge: true));
    }

    final shouldBan = await showDialog<bool>(
      context: context,
      builder:
          (context) => CustomModal(
            title: 'Ban User',
            content: const Text(
              'Are you sure you want to ban this user? They will not be able to access the app.',
            ),
            onClose: () => Navigator.pop(context, false),
          ),
    );

    if (shouldBan == true) {
      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(userId)
          .update({'isBanned': true});

      // Clean up the banned user's products
      await _authService.cleanupBannedUserProducts(userId);

      // 1. Get all product IDs from this seller
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('userId', isEqualTo: userId)
          .get();
      final productIds = productsSnapshot.docs.map((doc) => doc.id).toSet();

      if (productIds.isNotEmpty) {
        // 2. Find all unfinished orders containing these products
        final ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('orderStatus', whereIn: ['Processing', 'Shipped'])
            .get();

        for (final orderDoc in ordersSnapshot.docs) {
          final orderData = orderDoc.data() as Map<String, dynamic>;
          final items = (orderData['items'] as List<dynamic>? ?? []);
          final containsBannedProduct = items.any((item) =>
            productIds.contains(item['productId'])
          );
          if (containsBannedProduct) {
            // 3. Cancel the order
            await orderDoc.reference.update({'orderStatus': 'Canceled'});
          }
        }
      }
    }
  }

  Future<void> _unbanUser(BuildContext context, String userId) async {
    final shouldUnban = await showDialog<bool>(
      context: context,
      builder:
          (context) => CustomModal(
            title: 'Unban User',
            content: const Text('Are you sure you want to unban this user?'),
            onClose: () => Navigator.pop(context, false),
          ),
    );

    if (shouldUnban == true) {
      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(userId)
          .update({'isBanned': false});
    }
  }

  Future<void> _changeUserRole(
    BuildContext context,
    String userId,
    String newRole,
  ) async {
    final shouldChange = await showDialog<bool>(
      context: context,
      builder:
          (context) => CustomModal(
            title: 'Change Role',
            content: Text(
              'Are you sure you want to change the role to "$newRole"?',
            ),
            onClose: () => Navigator.pop(context, false),
          ),
    );

    if (shouldChange == true) {
      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(userId)
          .update({'role': newRole});
    }
  }

  // Modify the existing _matchesSearch method to include filters
  bool _matchesSearch(Map<String, dynamic> userData, String userId) {
    final query = _searchQuery.toLowerCase().trim();
    final String name = (userData['fullName'] ?? '').toString().toLowerCase();
    final String role = (userData['role'] ?? '').toString().toLowerCase();
    final bool isBanned = userData['isBanned'] ?? false;

    // Apply role filter
    if (_selectedRole != null &&
        _selectedRole != 'All Roles' &&
        role != _selectedRole?.toLowerCase()) {
      return false;
    }

    // Apply ban status filter
    if (_selectedBanStatus != null && _selectedBanStatus != 'All Status') {
      final isUserBanned = userData['isBanned'] ?? false;
      if (_selectedBanStatus == 'Banned' && !isUserBanned) return false;
      if (_selectedBanStatus == 'Active' && isUserBanned) return false;
    }

    // Apply search query
    if (query.isEmpty) return true;
    return name.contains(query) ||
        userId.toLowerCase().contains(query) ||
        role.contains(query);
  }

  // Add this widget for the filter row
  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Filter by Role',
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items:
                  _roleOptions.map((String role) {
                    return DropdownMenuItem(
                      value: role == 'All Roles' ? null : role,
                      child: Text(role),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedBanStatus,
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items:
                  _banStatusOptions.map((String status) {
                    return DropdownMenuItem(
                      value: status == 'All Status' ? null : status,
                      child: Text(status),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBanStatus = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Modify the build method to include the filter row
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, ID, or role...', // Updated hint text
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          _buildFilterRow(), // Add the filter row here
          const SizedBox(height: 8), // Add some spacing
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('accounts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;
                final filteredUsers =
                    users
                        .where(
                          (user) => _matchesSearch(
                            user.data() as Map<String, dynamic>,
                            user.id,
                          ),
                        )
                        .toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text('No users found matching your search'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final userData = user.data() as Map<String, dynamic>;
                    final userId = user.id;
                    final userName = userData['fullName'] ?? 'Unknown User';
                    final userRole = userData['role'] ?? 'buyer';
                    bool isBanned = userData['isBanned'] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        title: Text(userName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Role: $userRole'),
                            Text('ID: $userId'),
                            Text(
                              'Status: ${isBanned ? 'Banned' : 'Active'}',
                              style: TextStyle(
                                color: isBanned ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        trailing: TextButton(
                          onPressed:
                              () =>
                                  isBanned
                                      ? _unbanUser(context, userId)
                                      : _banUser(context, userId),
                          child: Text(
                            isBanned ? 'Unban' : 'Ban',
                            style: TextStyle(
                              color: isBanned ? Colors.blue : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
