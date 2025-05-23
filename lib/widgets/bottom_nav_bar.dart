import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    this.currentIndex = -1,
  }); // Default to -1 if not provided

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex:
          widget.currentIndex >= 0
              ? widget.currentIndex
              : 0, // Default to 0 if currentIndex is invalid
      onTap: (index) async {
        if (_isNavigating) return;

        setState(() {
          _isNavigating = true;
        });

        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home'); // Redirect to HomeScreen
            break;
          case 1:
            Navigator.pushNamed(
              context,
              '/notifications',
            ); // Redirect to NotificationsScreen
            break;
          case 2:
            // Check if the user is logged in before navigating to OrdersScreen
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              Navigator.pushNamed(
                context,
                '/orders',
              ); // Redirect to OrdersScreen
            } else {
              Navigator.pushNamed(context, '/sign_in').then((_) {
                // This runs after returning from sign-in screen
                if (mounted && FirebaseAuth.instance.currentUser != null) {
                  Navigator.pushNamed(context, '/orders');
                }
              });
            }
            break;
          case 3:
            // Check if the user is logged in before navigating to ProfileScreen
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              Navigator.pushNamed(
                context,
                '/profile',
              ); // Redirect to ProfileScreen
            } else {
              Navigator.pushNamed(context, '/sign_in').then((_) {
                // This runs after returning from sign-in screen
                if (mounted && FirebaseAuth.instance.currentUser != null) {
                  Navigator.pushNamed(context, '/profile');
                }
              });
            }
            break;
        }

        // Reset after a short delay
        await Future.delayed(Duration(milliseconds: 300));
        if (mounted) {
          setState(() {
            _isNavigating = false;
          });
        }
      },
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Orders',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
