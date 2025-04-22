import 'package:flutter/material.dart';
import 'order_status_item.dart';

class TrackOrder extends StatelessWidget {
  const TrackOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth <= 991;
        final isMobile = constraints.maxWidth <= 640;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              isMobile ? 16 : (isTablet ? 24 : 32),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 12 : (isTablet ? 16 : 24),
            isMobile ? 16 : (isTablet ? 20 : 24),
            isMobile ? 12 : (isTablet ? 16 : 24),
            isMobile ? 24 : (isTablet ? 32 : 40),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order Header
              Positioned(
                top: isMobile ? 16 : (isTablet ? 20 : 24),
                left: isMobile ? 16 : (isTablet ? 20 : 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        'https://cdn.builder.io/api/v1/image/assets/TEMP/ab0e68a6ba0c590baa743349a722d7163b2d1d1e?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Order #456765',
                      style: TextStyle(
                        fontFamily: 'Gabarito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF272727),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Order Status Items
              Column(
                children: [
                  OrderStatusItem(
                    imageUrl: 'https://cdn.builder.io/api/v1/image/assets/TEMP/f55c37a397be5cf5fb7fd283e7a7ae98c63da5b2?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                    status: 'Delivered',
                    date: '28 May',
                  ),
                  OrderStatusItem(
                    imageUrl: 'https://cdn.builder.io/api/v1/image/assets/TEMP/fb33143e03efe31d39e5744ba9d94b1ab8fae5a4?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                    status: 'Shipped',
                    date: '28 May',
                  ),
                  OrderStatusItem(
                    imageUrl: 'https://cdn.builder.io/api/v1/image/assets/TEMP/fb33143e03efe31d39e5744ba9d94b1ab8fae5a4?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                    status: 'Order Confirmed',
                    date: '28 May',
                  ),
                  OrderStatusItem(
                    imageUrl: 'https://cdn.builder.io/api/v1/image/assets/TEMP/fb33143e03efe31d39e5744ba9d94b1ab8fae5a4?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                    status: 'Order Placed',
                    date: '28 May',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Order Items Section
              const Text(
                'Order Items',
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF272727),
                ),
              ),

              const SizedBox(height: 16),

              // Order Items Container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.network(
                          'https://cdn.builder.io/api/v1/image/assets/TEMP/dc02b4da55a0e80d131168ad6c81dc2fdf12bb12?placeholderIfAbsent=true&apiKey=6802976d0a8e44c6943f4cc155e52295',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '4 items',
                          style: TextStyle(
                            fontFamily: 'CircularStd',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF272727),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'View All',
                      style: TextStyle(
                        fontFamily: 'Gabarito',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8E6CEF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Shipping Details Section
              const Text(
                'Shipping details',
                style: TextStyle(
                  fontFamily: 'Gabarito',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF272727),
                ),
              ),

              const SizedBox(height: 14),

              // Shipping Details Container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2715 Ash Dr. San Jose, South Dakota 83475',
                      style: TextStyle(
                        fontFamily: 'CircularStd',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF272727),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '121-224-7890',
                      style: TextStyle(
                        fontFamily: 'CircularStd',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF272727),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}