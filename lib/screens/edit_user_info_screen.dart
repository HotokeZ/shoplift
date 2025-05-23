import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'styles/about_yourself_screen_styles.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // Import for base64 encoding
import 'package:http/http.dart' as http;
import '../utils/app_icons.dart';

class EditUserInfoScreen extends StatefulWidget {
  const EditUserInfoScreen({super.key});

  @override
  _EditUserInfoScreenState createState() => _EditUserInfoScreenState();
}

class _EditUserInfoScreenState extends State<EditUserInfoScreen> {
  final TextEditingController _firstNameController =
      TextEditingController(); // Now used for full name
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;
  String? _avatarUrl;
  MemoryImage? _avatarImage; // For decoded Base64 avatar
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('accounts')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            _firstNameController.text = data?['fullName'] ?? '';
            _emailController.text = data?['email'] ?? '';
            _phoneController.text = data?['phone'] ?? '';

            // Load avatar from URL if available
            if (data?['avatarUrl'] != null) {
              _avatarUrl = data?['avatarUrl'];
              _selectedImage = null; // Clear any locally selected image
              _avatarImage = null; // Clear any Base64-decoded image
            } else if (data?['avatarBase64'] != null) {
              // Decode Base64 avatar if available
              final base64String = data?['avatarBase64'];
              final bytes = base64Decode(base64String);
              _selectedImage = null; // Clear any locally selected image
              _avatarUrl = null; // Clear any previous URL
              _avatarImage = MemoryImage(bytes); // Store the decoded image
            }
          });

          // Debugging: Print loaded data
          print('Loaded user data:');
          print('Full Name: ${_firstNameController.text}');
          print('Email: ${_emailController.text}');
          print('Phone: ${_phoneController.text}');
          print('Avatar URL: $_avatarUrl');
        } else {
          print('No user document found in Firestore.');
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    } else {
      print('No user is logged in.');
    }
  }

  Future<void> _saveUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is logged in.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? avatarUrl;

      // Upload the selected image to Cloudinary
      if (_selectedImage != null) {
        print('Uploading avatar image to Cloudinary...');
        avatarUrl = await uploadImageToCloudinary(_selectedImage!);
        if (avatarUrl != null) {
          print('Avatar uploaded successfully: $avatarUrl');
        } else {
          print('Failed to upload avatar image.');
        }
      } else {
        print('No avatar image selected.');
      }

      final userDoc = FirebaseFirestore.instance
          .collection('accounts')
          .doc(user.uid);

      final updatedData = {
        'fullName': _firstNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        if (avatarUrl != null) 'avatarUrl': avatarUrl, // Save Cloudinary URL
      };

      print('Updating user data: $updatedData');

      await userDoc.update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User information updated successfully!')),
      );
    } catch (e, stackTrace) {
      print('Error occurred while saving user info: $e');
      print('Stack trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user information: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _avatarImage = null; // Clear the decoded image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AboutYourselfScreenStyles.backgroundColor,
      body: SafeArea(
        // Ensures content is below the camera cutout
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: AboutYourselfScreenStyles.maxWidth,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AboutYourselfScreenStyles.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20), // Adjust spacing for the header
                  _buildHeader(context), // Add the header with the back button
                  const SizedBox(height: 49),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (_avatarUrl != null
                                        ? NetworkImage(_avatarUrl!)
                                        : const AssetImage(
                                          'assets/default_avatar.png',
                                        ))
                                    as ImageProvider,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.camera_alt,
                              size: 15,
                              color: AboutYourselfScreenStyles.primaryRed,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField('Full Name', _firstNameController),
                  const SizedBox(height: 24),
                  _buildTextField('Email Address', _emailController),
                  const SizedBox(height: 24),
                  _buildTextField('Phone Number', _phoneController),
                  const SizedBox(height: 56),
                  _SaveButton(onPressed: _isLoading ? null : _saveUserInfo),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header section with back button and title
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        _buildBackButton(context),

        // Title
        const Text(
          'Edit Your Information',
          style: AboutYourselfScreenStyles.titleStyle,
        ),

        // Empty container to balance the row
        const SizedBox(width: 40),
      ],
    );
  }

  /// Back button widget (reused from AddressScreen)
  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 48.0, // Adjust size for the back button
        height: 48.0,
        margin: const EdgeInsets.only(left: 0.0), // Move to the left edge
        decoration: BoxDecoration(
          color: AboutYourselfScreenStyles.greyBackground,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Center(
          child: SizedBox(
            width: 20.0, // Adjust icon size
            height: 20.0,
            child: AppIcons.backArrowIcon(), // Use the same back arrow icon
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AboutYourselfScreenStyles.bodyStyle),
        const SizedBox(height: 13),
        TextField(
          controller: controller,
          readOnly:
              label == 'Email Address', // Make the email field non-editable
          decoration: InputDecoration(
            filled: true,
            fillColor: AboutYourselfScreenStyles.greyBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AboutYourselfScreenStyles.borderRadius,
              ),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _SaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: AboutYourselfScreenStyles.buttonHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AboutYourselfScreenStyles.primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AboutYourselfScreenStyles.borderRadius,
              ),
            ),
          ),
          child: const Text(
            'Save',
            style: AboutYourselfScreenStyles.buttonTextStyle,
          ),
        ),
      ),
    );
  }
}

Future<String?> uploadImageToCloudinary(File imageFile) async {
  const cloudName = 'duw2eq9gt'; // Replace with your Cloudinary cloud name
  const uploadPreset = 'shoplift'; // Replace with your updated preset name

  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );

  try {
    // Create a multipart request
    final request = http.MultipartRequest('POST', url);

    // Add the file
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    // Add the upload preset
    request.fields['upload_preset'] = uploadPreset;

    // Send the request
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      // Get the secure URL of the uploaded image
      final imageUrl = jsonResponse['secure_url'];
      print('Image uploaded to Cloudinary: $imageUrl');
      return imageUrl;
    } else {
      print('Failed to upload image: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error uploading image to Cloudinary: $e');
    return null;
  }
}
