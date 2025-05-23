import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSellerApprovalScreen extends StatefulWidget {
  final String? initialApplicantId;

  const AdminSellerApprovalScreen({
    Key? key,
    this.initialApplicantId,
  }) : super(key: key);

  @override
  _AdminSellerApprovalScreenState createState() =>
      _AdminSellerApprovalScreenState();
}

class _AdminSellerApprovalScreenState extends State<AdminSellerApprovalScreen> {
  String _filterStatus = 'pending';

  Future<void> _approveApplication(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(userId)
          .update({'role': 'seller'});

      await FirebaseFirestore.instance
          .collection('sellerApplications')
          .doc(userId)
          .update({'status': 'approved'});

      debugPrint('Application approved for user: $userId');
    } catch (e) {
      debugPrint('Error approving application: $e');
    }
  }

  Future<void> _rejectApplication(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('sellerApplications')
          .doc(userId)
          .update({'status': 'rejected'});

      debugPrint('Application rejected for user: $userId');
    } catch (e) {
      debugPrint('Error rejecting application: $e');
    }
  }

  Future<void> _confirmAction(String userId, String action) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$action Application'),
            content: Text('Are you sure you want to $action this application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(action, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (result == true) {
      if (action == 'approve') {
        await _approveApplication(userId);
      } else {
        await _rejectApplication(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DropdownButton<String>(
            value: _filterStatus,
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'approved', child: Text('Approved')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (value) {
              setState(() {
                _filterStatus = value!;
              });
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.initialApplicantId != null
                  ? FirebaseFirestore.instance
                      .collection('sellerApplications')
                      .where(FieldPath.documentId, isEqualTo: widget.initialApplicantId)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('sellerApplications')
                      .where('status', isEqualTo: _filterStatus)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No applications found'));
                }

                final applications = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final application = applications[index];
                    final data = application.data() as Map<String, dynamic>;

                    // Use the document ID as the userId
                    final userId = application.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      leading: const Icon(Icons.store, size: 50), // Placeholder for a business icon
                      title: Text(data['shopName'] ?? 'Unknown Shop'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${data['email'] ?? 'No email provided'}'),
                          Text('Phone: ${data['phoneNumber'] ?? 'No phone number provided'}'),
                          Text('Address: ${data['pickupAddress']['street'] ?? 'No address provided'}, '
                              '${data['pickupAddress']['city'] ?? ''}, '
                              '${data['pickupAddress']['province'] ?? ''}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _confirmAction(userId, 'approve'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _confirmAction(userId, 'reject'),
                          ),
                        ],
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
