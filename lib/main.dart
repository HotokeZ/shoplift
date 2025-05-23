import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/order_screen_items.dart';
import 'screens/profile_screen.dart';
import 'splash_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/orders_screen.dart';
import 'widgets/auth_wrapper.dart';
import 'widgets/error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ErrorBoundary(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoplift',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(child: const SplashScreen()),
      routes: {
        '/home': (context) => AuthWrapper(child: const HomeScreen()),
        '/notifications': (context) => AuthWrapper(child: const NotificationsScreen()),
        '/orders': (context) => AuthWrapper(child: const OrdersScreenItems()),
        '/profile': (context) => AuthWrapper(child: const ProfileScreen()),
        '/cart': (context) => AuthWrapper(child: const CartScreen()),
        '/sign_in': (context) => const SignInScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        );
      },
    );
  }
}
