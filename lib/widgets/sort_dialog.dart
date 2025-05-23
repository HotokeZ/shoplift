import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SortDialog extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortSelected;

  const SortDialog({
    Key? key,
    required this.currentSort,
    required this.onSortSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSortOption(context, 'Latest'),
          _buildSortOption(context, 'Price: Low to High'),
          _buildSortOption(context, 'Price: High to Low'),
        ],
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String option) {
    return ListTile(
      title: Text(option),
      trailing: currentSort == option ? const Icon(Icons.check) : null,
      onTap: () => onSortSelected(option),
    );
  }
}
