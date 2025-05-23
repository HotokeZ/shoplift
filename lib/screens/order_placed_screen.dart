import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_checkmark.dart';
import '../screens/order_Screen_items.dart';


/// A screen that displays a success message after an order has been placed
class OrderPlacedScreen extends StatefulWidget {
  /// Callback function when the "See Order details" button is pressed
  final VoidCallback? onSeeOrderDetails;

  const OrderPlacedScreen({Key? key, this.onSeeOrderDetails}) : super(key: key);

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Create pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: AppTheme.white,
        child: Column(
          children: [
            // Top gradient section with checkmark
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  // Gradient background
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryRed, Color(0xFFFF6B6B)],
                      ),
                    ),
                  ),

                  // Pulse effect
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 2,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: _pulseAnimation.value,
                              colors: const [
                                Colors.transparent,
                                Color(0x1AFFFFFF),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Checkmark
                  const Center(
                    child: AnimatedCheckmark(
                      size: 120,
                      checkmarkColor: AppTheme.primaryRed,
                      backgroundColor: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section with text and button
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: AppTheme.lightGray,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 70,
                    ), // Space for the checkmark that overlaps
                    // Success text
                    Text(
                      'Order Placed Successfully',
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 25),

                    // Optional confirmation text
                    const Text(
                      'You will receive an email confirmation',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 18,
                        color: AppTheme.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // See order details button
                   SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OrdersScreenItems()),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryRed,
      foregroundColor: AppTheme.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      elevation: 0,
    ),
    child: const Text(
      'See Order details',
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
