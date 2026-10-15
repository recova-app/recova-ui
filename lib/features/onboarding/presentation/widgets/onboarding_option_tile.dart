import 'package:flutter/material.dart';

/// Selectable question option tile for onboarding questionnaires.
///
/// Supports single-selection and multi-selection styles, applying
/// active and inactive tokens from [ThemeData.colorScheme].
class OnboardingOptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const OnboardingOptionTile({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: padding,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? colorScheme.primary.withOpacity(0.12)
                      : colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(borderRadius),
              border:
                  isSelected
                      ? Border.all(color: colorScheme.primary, width: 2)
                      : Border.all(
                        color: colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
