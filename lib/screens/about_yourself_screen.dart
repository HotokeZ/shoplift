import 'package:flutter/material.dart';
import 'styles/about_yourself_screen_styles.dart';

class AboutYourselfScreen extends StatefulWidget {
  const AboutYourselfScreen({super.key});

  @override
  _AboutYourselfScreenState createState() => _AboutYourselfScreenState();
}

class _AboutYourselfScreenState extends State<AboutYourselfScreen> {
  String selectedGender = 'men';
  String? selectedAgeRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AboutYourselfScreenStyles.backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: AboutYourselfScreenStyles.maxWidth),
            padding: const EdgeInsets.symmetric(
              horizontal: AboutYourselfScreenStyles.horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 161),
                const Text(
                  'Tell us About yourself',
                  style: AboutYourselfScreenStyles.titleStyle,
                ),
                const SizedBox(height: 49),
                const Text(
                  'Who do you shop for ?',
                  style: AboutYourselfScreenStyles.bodyStyle,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _GenderButton(
                        label: 'Men',
                        isSelected: selectedGender == 'men',
                        onTap: () => setState(() => selectedGender = 'men'),
                      ),
                    ),
                    const SizedBox(width: 31),
                    Expanded(
                      child: _GenderButton(
                        label: 'Women',
                        isSelected: selectedGender == 'women',
                        onTap: () => setState(() => selectedGender = 'women'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 56),
                const Text(
                  'How Old are you ?',
                  style: AboutYourselfScreenStyles.bodyStyle,
                ),
                const SizedBox(height: 13),
                _AgeRangeSelector(
                  value: selectedAgeRange,
                  onChanged: (value) => setState(() => selectedAgeRange = value),
                ),
                const SizedBox(height: 24),
                _FinishButton(
                  onPressed: () {
                    // Handle finish button press
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AboutYourselfScreenStyles.buttonHeight,
        decoration: BoxDecoration(
          color: isSelected
              ? AboutYourselfScreenStyles.primaryRed
              : AboutYourselfScreenStyles.greyBackground,
          borderRadius: BorderRadius.circular(AboutYourselfScreenStyles.borderRadius),
        ),
        child: Center(
          child: Text(
            label,
            style: AboutYourselfScreenStyles.bodyStyle.copyWith(
              color: isSelected ? Colors.white : AboutYourselfScreenStyles.textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeRangeSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _AgeRangeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AboutYourselfScreenStyles.greyBackground,
        borderRadius: BorderRadius.circular(AboutYourselfScreenStyles.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value ?? 'Age Range',
            style: AboutYourselfScreenStyles.bodyStyle,
          ),
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AboutYourselfScreenStyles.textColor,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _AgeRangeBottomSheet(
                  currentValue: value,
                  onSelect: onChanged,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AgeRangeBottomSheet extends StatelessWidget {
  final String? currentValue;
  final ValueChanged<String?> onSelect;

  const _AgeRangeBottomSheet({
    super.key,
    required this.currentValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final ageRanges = [
      '18-24',
      '25-34',
      '35-44',
      '45-54',
      '55+',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ageRanges.map((range) {
          return ListTile(
            title: Text(range, style: AboutYourselfScreenStyles.bodyStyle),
            selected: range == currentValue,
            onTap: () {
              onSelect(range);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _FinishButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _FinishButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: AboutYourselfScreenStyles.buttonHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AboutYourselfScreenStyles.primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AboutYourselfScreenStyles.borderRadius),
            ),
          ),
          child: const Text(
            'Finish',
            style: AboutYourselfScreenStyles.buttonTextStyle,
          ),
        ),
      ),
    );
  }
}