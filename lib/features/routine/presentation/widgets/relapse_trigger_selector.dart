import 'package:flutter/material.dart';

class TriggerOption {
  final IconData icon;
  final String label;
  final String value;

  const TriggerOption({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class RelapseTriggerSelector extends StatelessWidget {
  final Set<String> selectedTriggers;
  final ValueChanged<String>? onTriggerToggled;
  final bool isEnabled;
  final List<TriggerOption> triggers;

  static const List<TriggerOption> defaultTriggers = [
    TriggerOption(
      icon: Icons.hourglass_empty_rounded,
      label: 'Boredom',
      value: 'Boredom',
    ),
    TriggerOption(
      icon: Icons.psychology_rounded,
      label: 'Stress',
      value: 'Stress',
    ),
    TriggerOption(
      icon: Icons.phone_android_rounded,
      label: 'Media',
      value: 'Media',
    ),
    TriggerOption(icon: Icons.mood_rounded, label: 'Mood', value: 'Mood'),
    TriggerOption(
      icon: Icons.location_on_rounded,
      label: 'Location',
      value: 'Location',
    ),
  ];

  const RelapseTriggerSelector({
    super.key,
    required this.selectedTriggers,
    this.onTriggerToggled,
    this.isEnabled = true,
    this.triggers = defaultTriggers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          triggers.map((trigger) {
            final isSelected = selectedTriggers.contains(trigger.value);
            return GestureDetector(
              onTap:
                  isEnabled
                      ? () => onTriggerToggled?.call(trigger.value)
                      : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trigger.icon,
                      size: 18,
                      color:
                          isSelected
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trigger.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color:
                            isSelected ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
