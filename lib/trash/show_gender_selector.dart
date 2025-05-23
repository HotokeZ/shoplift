import 'package:flutter/material.dart';
import '../widgets/gender_selector.dart';

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
      builder:
          (context) => GenderSelectionModal(
            onClose: () => Navigator.pop(context),
            onSelect: onSelect,
          ),
    );
  } else {
    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: GenderSelectionModal(
              onClose: () => Navigator.pop(context),
              onSelect: onSelect,
            ),
          ),
    );
  }
}
