import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/payment_option_item.dart';
import '../screens/add_card_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A screen that displays available payment methods and allows selection
class PaymentScreen extends StatefulWidget {
  /// Callback when a payment method is selected
  final Function(String, String)? onPaymentSelected;

  const PaymentScreen({
    Key? key,
    this.onPaymentSelected,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedPaymentId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _selectPayment(String id, String displayValue) {
    setState(() {
      selectedPaymentId = id;
    });

    if (widget.onPaymentSelected != null) {
      widget.onPaymentSelected!(id, displayValue);
    }
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

 @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  double horizontalPadding = 48.0;
  if (screenWidth <= AppTheme.breakpointTablet) horizontalPadding = 24.0;
  if (screenWidth <= AppTheme.breakpointMobile) horizontalPadding = 16.0;

  final String userId = _auth.currentUser!.uid; // Get user ID

  return Scaffold(
    backgroundColor: AppTheme.white,
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: 80,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTitle(), // Updated title method
              const SizedBox(height: 16),

              // Cards Section
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text('Cards', style: AppTheme.subtitleStyle),
              ),

              /// 🔥 Stream of user's cards
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('accounts')
                    .doc(userId)
                    .collection('cards')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('No cards found.'),
                    );
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final cardId = doc.id;
                      final cardNumber = data['cardNumber'] ?? '';
                      final display = cardNumber.length >= 4
                          ? '**** ${cardNumber.substring(cardNumber.length - 4)}'
                          : '****';

                      return PaymentOptionItem(
                        id: cardId,
                        displayValue: display,
                        icon: _buildCardIcon(),
                        isSelected: selectedPaymentId == cardId,
                        onTap: (id, _) {
                          _showCardOptionsModal(doc.id, data);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),

    // Floating plus icon button to add a card
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddCardScreen(userId: userId), // Pass the userId
          ),
        );
      },
      backgroundColor: AppTheme.primaryRed,
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );
}

Widget _buildTitle() {
  return Padding(
    padding: const EdgeInsets.only(top: 11),
    child: Stack(
      children: [
        _buildBackButton(), // Back button
        Align(
          alignment: Alignment.center,
          child: Text('Payment', style: AppTheme.subtitleStyle),
        ),
      ],
    ),
  );
}

Widget _buildBackButton() => GestureDetector(
  onTap: _goBack,
  child: Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: AppTheme.lightGray,
      borderRadius: BorderRadius.circular(AppTheme.circularRadius),
    ),
    child: Center(
      child: SizedBox(
        width: 16,
        height: 16,
        child: CustomPaint(painter: BackArrowPainter()),
      ),
    ),
  ),
);


  void _showCardOptionsModal(String cardId, Map<String, dynamic> cardData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String expiry = cardData['expiry'] ?? 'No expiry set'; 
        print('Card Expiry: $expiry');

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); 
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.black54, 
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Card Details', 
                style: AppTheme.subtitleStyle.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                'Card Number: ${cardData['cardNumber']}',
                style: TextStyle(color: Colors.black54),
              ),
              Text(
                'Expiry: $expiry', 
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCardScreen(
                              userId: _auth.currentUser!.uid,
                              cardId: cardId,
                              cardData: cardData,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed.withOpacity(0.8),
                      ),
                      child: const Text('Edit', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _firestore
                            .collection('accounts')
                            .doc(_auth.currentUser!.uid)
                            .collection('cards')
                            .doc(cardId)
                            .delete();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.withOpacity(0.6),
                      ),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardIcon() {
    return SvgPicture.string(
      '''
      <svg width="24" height="16" viewBox="0 0 24 16" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="8" cy="8" r="8" fill="#F4BD2F"></circle>
        <circle cx="16" cy="8" r="8" fill="#FA3636"></circle>
      </svg>
      ''',
      width: 24,
      height: 16,
    );
  }
}
