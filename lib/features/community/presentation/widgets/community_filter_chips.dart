import 'package:flutter/material.dart';

class CommunityFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const CommunityFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = filters[index];
          final selected = selectedFilter == label;
          return GestureDetector(
            onTap: () => onFilterSelected(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color:
                      selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                ),
                boxShadow:
                    selected
                        ? [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                        : const [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.circle, size: 7, color: Colors.white),
                    ),
                  Text(
                    label,
                    style: TextStyle(
                      color:
                          selected
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
