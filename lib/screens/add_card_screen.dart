import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/app_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCardScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onCardAdded;
  final String? cardId;
  final String userId;
  final Map<String, dynamic>? cardData;

  AddCardScreen({
    Key? key,
    this.onCardAdded,
    this.cardId,
    this.cardData,
    required this.userId,
  }) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _cardNumberController = TextEditingController();
  final _ccvController = TextEditingController();
  final _expiryController = TextEditingController();
  final _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _addCardFormKey = GlobalKey<FormState>();

  final Map<String, bool> _focusStates = {
    'cardNumber': false,
    'ccv': false,
    'expiry': false,
    'name': false,
  };

  @override
  void initState() {
    super.initState();
    if (widget.cardData != null) {
      _cardNumberController.text = widget.cardData!['cardNumber'] ?? '';
      _ccvController.text = widget.cardData!['ccv'] ?? '';
      _expiryController.text = widget.cardData!['expiry'] ?? '';
      _nameController.text = widget.cardData!['name'] ?? '';
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _ccvController.dispose();
    _expiryController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      final cardData = {
        'cardNumber': _cardNumberController.text,
        'ccv': _ccvController.text,
        'expiry': _expiryController.text,
        'name': _nameController.text,
        'addedAt': FieldValue.serverTimestamp(),
      };

      try {
        final cardRef = FirebaseFirestore.instance
            .collection('accounts')
            .doc(user.uid)
            .collection('cards');

        if (widget.cardId != null) {
          // Update existing card
          await cardRef.doc(widget.cardId).update(cardData);
        } else {
          // Add new card
          await cardRef.add(cardData);
        }

        if (widget.onCardAdded != null) {
          widget.onCardAdded!(cardData);
        }

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save card: $e")),
        );
      }
    }
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required String fieldKey,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      validator: validator,
      textCapitalization: textCapitalization,
      style: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppTheme.darkText,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0x80272727),
        ),
        filled: true,
        fillColor: _focusStates[fieldKey] == true
            ? const Color(0xFFEBEBEB)
            : AppTheme.lightGray,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 19),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryRed, width: 1),
        ),
        counterText: '',
      ),
      onTap: () {
        setState(() {
          _focusStates[fieldKey] = true;
        });
      },
      onChanged: (_) {
        setState(() {
          _focusStates[fieldKey] = true;
        });
      },
      onFieldSubmitted: (_) {
        setState(() {
          _focusStates[fieldKey] = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(27, 63, 27, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: _handleBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius:
                              BorderRadius.circular(AppTheme.circularRadius),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CustomPaint(
                              painter: BackArrowPainter(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    widget.cardId != null ? 'Edit Card' : 'Add Card',
                    style: AppTheme.subtitleStyle.copyWith(
                      fontFamily: 'Gabarito',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _cardNumberController,
                            placeholder: 'Card Number',
                            fieldKey: 'cardNumber',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(16),
                              _CardNumberFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter card number';
                              }
                              if (value.replaceAll(' ', '').length < 16) {
                                return 'Please enter a valid card number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _ccvController,
                                  placeholder: 'CCV',
                                  fieldKey: 'ccv',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter CCV';
                                    }
                                    if (value.length < 3) {
                                      return 'CCV must be at least 3 digits';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _expiryController,
                                  placeholder: 'MM/YY',
                                  fieldKey: 'expiry',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                    _ExpiryDateFormatter(),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter expiry date';
                                    }
                                    if (value.length < 5) {
                                      return 'Please enter a valid date';
                                    }
                                    final parts = value.split('/');
                                    if (parts.length != 2) return 'Invalid format';
                                    final month = int.tryParse(parts[0]);
                                    if (month == null || month < 1 || month > 12) {
                                      return 'Invalid month';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _nameController,
                            placeholder: 'Cardholder Name',
                            fieldKey: 'name',
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter cardholder name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: _handleSave,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius:
                        BorderRadius.circular(AppTheme.circularRadius),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Save',
                    style: AppTheme.buttonTextStyleNew,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    String text = newValue.text.replaceAll(RegExp(r'\D'), '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    String text = newValue.text.replaceAll(RegExp(r'\D'), '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && i != text.length - 1) {
        buffer.write('/');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
