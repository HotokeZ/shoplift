import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/edit_user_info_screen.dart';

/// Widget that displays user profile information
class ProfileInfoSection extends StatelessWidget {
  /// URL for the user's avatar image
  final String avatarUrl;

  /// User's full name
  final String name;

  /// User's email address
  final String email;

  /// User's phone number
  final String phone;

  const ProfileInfoSection({
    Key? key,
    required this.avatarUrl,
    required this.name,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive margins
    double topMargin = 40.0;
    if (screenWidth <= AppTheme.breakpointTablet) {
      topMargin = 20.0;
    }
    if (screenWidth <= AppTheme.breakpointMobile) {
      topMargin = 10.0;
    }

    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(avatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // User information
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Gabarito',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.darkText,
                  ),
                ),

                // Email
                Text(
                  email,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: AppTheme.secondaryText,
                  ),
                ),

                // Phone
                Text(
                  phone,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: AppTheme.secondaryText,
                  ),
                ),

                // Edit button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditUserInfoScreen(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'Gabarito',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}