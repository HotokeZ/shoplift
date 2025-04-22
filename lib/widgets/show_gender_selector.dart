
import 'package:flutter/material.dart';
import 'gender_selector.dart';

Future<void> showGenderSelector(
  BuildContext context, {
  required Function(String) onSelect,
}) async {
  final screenSize = MediaQuery.of(context).size;
  final bool isMobile = screenSize.width <= 640;

  if (isMobile) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GenderSelector(
        onClose: () => Navigator.pop(context),
        onSelect: onSelect,
      ),
    );
  } else {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GenderSelector(
          onClose: () => Navigator.pop(context),
          onSelect: onSelect,
        ),
      ),
    );
  }
}