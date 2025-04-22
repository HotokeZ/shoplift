import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class GenderSelector extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String) onSelect;

  const GenderSelector({
    Key? key,
    required this.onClose,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width <= 640;
    final bool isTablet = screenSize.width <= 991 && screenSize.width > 640;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: isTablet ? 480 : 600,
        maxHeight: isMobile ? MediaQuery.of(context).size.height * 0.85 : double.infinity,
      ),
      margin: isMobile
          ? null
          : const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: isMobile
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isMobile ? 16 : isTablet ? 20 : 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => selectedGender = null);
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  'Gender',
                  style: GoogleFonts.gabarito(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: widget.onClose,
                  color: AppColors.text,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _GenderOption(
                      label: 'Men',
                      isSelected: selectedGender == 'Men',
                      onTap: () {
                        setState(() => selectedGender = 'Men');
                        widget.onSelect('Men');
                      },
                    ),
                    const SizedBox(height: 16),
                    _GenderOption(
                      label: 'Women',
                      isSelected: selectedGender == 'Women',
                      onTap: () {
                        setState(() => selectedGender = 'Women');
                        widget.onSelect('Women');
                      },
                    ),
                    const SizedBox(height: 16),
                    _GenderOption(
                      label: 'Kids',
                      isSelected: selectedGender == 'Kids',
                      onTap: () {
                        setState(() => selectedGender = 'Kids');
                        widget.onSelect('Kids');
                      },
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

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 640;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 16 : 18,
          horizontal: isMobile ? 24 : 34,
        ),
        decoration: BoxDecoration(
          color: AppColors.optionBackground,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.text,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Icon(
                Icons.check,
                size: 16,
                color: AppColors.text,
              ),
            ],
          ],
        ),
      ),
    );
  }
}