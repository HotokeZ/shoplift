import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../utils/app_icons.dart';
import '../utils/session_manager.dart'; // Import SessionManager
import 'address_screen.dart';
import 'package:flutter/services.dart'; // Import for keyboard utilities

/// Screen for adding a new address
class AddAddressScreen extends StatefulWidget {
  final String userId; // Accept userId as a parameter
  final VoidCallback? onBack; // Add onBack callback
  final Map<String, dynamic>? addressData;
  final String? docId;

  const AddAddressScreen({
    Key? key,
    required this.userId,
    this.onBack,
    this.addressData,
    this.docId,
  }) : super(key: key);

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  // Text controllers for form fields
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _barangayController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _contactNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _contactNumberFocusNode.addListener(() {
      if (_contactNumberFocusNode.hasFocus &&
          _contactNumberController.text.isEmpty) {
        _contactNumberController.text = '0';
        // Position cursor after the "0"
        _contactNumberController.selection = TextSelection.fromPosition(
          TextPosition(offset: _contactNumberController.text.length),
        );
      }
    });

    if (widget.addressData != null) {
      _streetController.text = widget.addressData!['street'] ?? '';
      _barangayController.text = widget.addressData!['barangay'] ?? '';
      _cityController.text = widget.addressData!['cityOrMunicipality'] ?? '';
      _provinceController.text = widget.addressData!['province'] ?? '';
      _fullNameController.text = widget.addressData!['fullName'] ?? '';
      _contactNumberController.text =
          widget.addressData!['contactNumber'] ?? '';
      _zipController.text = widget.addressData!['zip'] ?? '';
    }

    print(
      'AddAddressScreen: initState called.',
    ); // Debug log to confirm initState is executed

    // Log the current user state when opening the screen
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('AddAddressScreen: User is logged in with UID: ${currentUser.uid}');
    } else {
      print('AddAddressScreen: No user is logged in.');
    }

    // Listen to authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('AddAddressScreen: User logged out or session expired.');
      } else {
        print('AddAddressScreen: User is logged in with UID: ${user.uid}');
      }
    });
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _barangayController.dispose();
    _provinceController.dispose();
    _fullNameController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _contactNumberFocusNode.dispose();
    super.dispose();
  }

  // Handle save button press
  void _handleSave() async {
    // Check if any field is empty
    if (_streetController.text.isEmpty ||
        _barangayController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _provinceController.text.isEmpty ||
        _fullNameController.text.isEmpty ||
        _contactNumberController.text.isEmpty ||
        _zipController.text.isEmpty) {
      // Show more descriptive error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required. Please complete the form.'),
        ),
      );
      return;
    }

    // Validate phone number is digits only
    if (_contactNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number is required.')),
      );
      return;
    }

    // Validate phone number is exactly 11 digits (ignoring spaces)
    final digitsOnly = _contactNumberController.text.replaceAll(' ', '');
    if (digitsOnly.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number must be 11 digits')),
      );
      return;
    }

    try {
      final addressesCollection = FirebaseFirestore.instance
          .collection('accounts')
          .doc(widget.userId)
          .collection('addresses');

      if (widget.docId != null) {
        // Update existing address
        await addressesCollection.doc(widget.docId).update({
          'street': _streetController.text,
          'barangay': _barangayController.text,
          'cityOrMunicipality': _cityController.text,
          'province': _provinceController.text,
          'fullName': _fullNameController.text,
          'contactNumber': _contactNumberController.text,
          'zip': _zipController.text,
        });
      } else {
        // Add new address
        await addressesCollection.add({
          'street': _streetController.text,
          'barangay': _barangayController.text,
          'cityOrMunicipality': _cityController.text,
          'province': _provinceController.text,
          'fullName': _fullNameController.text,
          'contactNumber': _contactNumberController.text,
          'zip': _zipController.text,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving address: $e')));
    }
  }

  Future<void> _saveAddress() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final street = _streetController.text.trim();
    final barangay = _barangayController.text.trim();
    final city = _cityController.text.trim();
    final province = _provinceController.text.trim();

    // Validations
    if (name.isEmpty || name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid name (at least 3 characters).'),
        ),
      );
      return;
    }

    final phoneRegex = RegExp(r'^\+63\d{10}$');
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid phone number. Use +63 followed by 10 digits (e.g. +639123456789).',
          ),
        ),
      );
      return;
    }

    if (street.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter street details.')));
      return;
    }

    if (barangay.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter your barangay.')));
      return;
    }

    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your city or municipality.')),
      );
      return;
    }

    if (province.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter your province.')));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('addresses')
          .add({
            'name': name,
            'phone': phone,
            'street': street,
            'barangay': barangay,
            'cityOrMunicipality': city,
            'province': province,
            'timestamp': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Address added successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving address: $e')));
    }
  }

  // Handle back button press
  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback check for user state in build method
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print(
        'AddAddressScreen (build): User is logged in with UID: ${currentUser.uid}',
      );
    } else {
      print('AddAddressScreen (build): No user is logged in.');
    }

    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine responsive padding based on screen width
    EdgeInsets screenPadding;
    if (screenWidth <= AppTheme.mobileBreakpoint) {
      screenPadding = const EdgeInsets.all(16.0);
    } else if (screenWidth <= AppTheme.tabletBreakpoint) {
      screenPadding = const EdgeInsets.all(24.0);
    } else {
      screenPadding = const EdgeInsets.all(48.0);
    }

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: GestureDetector(
          onTap:
              () =>
                  FocusScope.of(
                    context,
                  ).unfocus(), // Dismiss keyboard on tap outside
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: screenPadding.copyWith(
                    bottom:
                        screenPadding.bottom +
                        80.0, // Add space for the fixed button
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Main content
                      Container(
                        width: double.infinity,
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height, // Ensure full height
                        color: AppTheme.white,
                        padding: screenPadding.copyWith(
                          top:
                              screenPadding.top +
                              40.0, // Lowered the form further
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title
                            Padding(
                              padding: const EdgeInsets.only(top: 74.0),
                              child: Text(
                                'Add Address',
                                style: TextStyle(
                                  fontFamily: 'Circular Std',
                                  fontSize:
                                      screenWidth <= AppTheme.mobileBreakpoint
                                          ? 18.0
                                          : 20.0, // Increased font size
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.darkText,
                                ),
                              ),
                            ),

                            // Street Address Input
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: _buildTextField(
                                controller: _streetController,
                                placeholder: 'Street Address',
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: _buildTextField(
                                controller: _barangayController,
                                placeholder: 'Barangay',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: _buildTextField(
                                controller: _cityController,
                                placeholder: 'City',
                              ),
                            ),

                            // State and Zip Code Inputs (side by side)
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: _buildStateZipRow(screenWidth),
                            ),

                            // Contact Information Title
                            Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontFamily: 'Circular Std',
                                  fontSize:
                                      screenWidth <= AppTheme.mobileBreakpoint
                                          ? 18.0
                                          : 20.0, // Increased font size
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.darkText,
                                ),
                              ),
                            ),

                            // Full Name Input
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: _buildTextField(
                                controller: _fullNameController,
                                placeholder: 'Full Name',
                              ),
                            ),

                            // Contact Number Input
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: _buildTextField(
                                controller: _contactNumberController,
                                placeholder: 'Contact Number (+63)',
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _PhoneNumberFormatter(),
                                ],
                                keyboardType: TextInputType.number,
                                focusNode:
                                    _contactNumberFocusNode, // Add this line
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Back button (fixed at top-left corner)
              Positioned(top: 16.0, left: 16.0, child: _buildBackButton()),

              // Save button (fixed at bottom)
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: _buildSaveButton(screenWidth),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Back button widget
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: _handleBack,
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Center(
          child: SizedBox(
            width: 16.0,
            height: 16.0,
            child:
                AppIcons.backArrowIcon(), // Use the back arrow icon from AppIcons instead of BackArrowPainter
          ),
        ),
      ),
    );
  }

  // Text field widget with custom styling
  // Modify the _buildTextField method to accept inputFormatters parameter
  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    double? width,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType, // Add this parameter
    FocusNode? focusNode, // Add this parameter
  }) {
    return Container(
      width: width ?? double.infinity,
      height: 56.0,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType, // Use the parameter here
        focusNode: focusNode, // Use the focus node here
        style: const TextStyle(
          fontFamily: 'Helvetica Now Text Medium',
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          color: AppTheme.darkText,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(
            fontFamily: 'Helvetica Now Text Medium',
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: AppTheme.darkText.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 19.0,
          ),
        ),
      ),
    );
  }

  // Row with State and Zip Code fields
  Widget _buildStateZipRow(double screenWidth) {
    // For mobile screens, stack the fields vertically
    if (screenWidth <= AppTheme.tabletBreakpoint) {
      return Column(
        children: [
          _buildTextField(
            controller: _provinceController,
            placeholder: 'Province',
          ),
          const SizedBox(height: 16.0),
          _buildTextField(controller: _zipController, placeholder: 'Zip Code'),
        ],
      );
    }

    // For larger screens, place fields side by side
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _barangayController,
            placeholder: 'Barangay',
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildTextField(
            controller: _provinceController,
            placeholder: 'Province',
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: _buildTextField(
            controller: _zipController,
            placeholder: 'Zip Code',
          ),
        ),
      ],
    );
  }

  // Save button widget
  Widget _buildSaveButton(double screenWidth) {
    // Calculate max width based on screen size
    double maxWidth;
    if (screenWidth <= AppTheme.mobileBreakpoint) {
      maxWidth = screenWidth - 32.0;
    } else {
      maxWidth = screenWidth - 48.0;
    }

    return Center(
      child: Container(
        width: maxWidth,
        height: 56.0,
        decoration: BoxDecoration(
          color: AppTheme.primaryRed,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: TextButton(
          onPressed: _handleSave,
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 16.0),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
            ),
          ),
          child: Text(
            'Save',
            style: TextStyle(
              fontFamily: 'Circular Std',
              fontSize: screenWidth <= AppTheme.mobileBreakpoint ? 14.0 : 16.0,
              fontWeight: FontWeight.w400,
              color: AppTheme.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Add this class at the bottom of the file (before the closing brace)

// Custom formatter for Philippine mobile number format (0916 975 9975)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Get digits only from the new value
    String numbersOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Always ensure the first digit is '0'
    if (numbersOnly.isEmpty) {
      numbersOnly = '0';
    } else if (!numbersOnly.startsWith('0')) {
      // If user tried to change first digit, force it to be '0'
      numbersOnly =
          '0' +
          numbersOnly.substring(
            0,
            numbersOnly.length > 10 ? 10 : numbersOnly.length,
          );
    }

    // Limit to 11 digits (including the fixed '0')
    if (numbersOnly.length > 11) {
      numbersOnly = numbersOnly.substring(0, 11);
    }

    // Format the number with spaces in 4-3-4 pattern
    final buffer = StringBuffer();
    for (int i = 0; i < numbersOnly.length; i++) {
      // Add space after position 3 (4th digit) and position 6 (7th digit)
      if (i == 4 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(numbersOnly[i]);
    }

    String formattedNumber = buffer.toString();

    // Calculate cursor position, ensuring it's never before the first digit
    int cursorPos =
        newValue.selection.end +
        (formattedNumber.length - newValue.text.length);
    if (cursorPos < 1) cursorPos = 1; // Prevent cursor before the first '0'
    if (cursorPos > formattedNumber.length) cursorPos = formattedNumber.length;

    return TextEditingValue(
      text: formattedNumber,
      selection: TextSelection.collapsed(offset: cursorPos),
    );
  }
}
