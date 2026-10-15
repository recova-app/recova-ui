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
                          ? const Color(0xFF136E4D)
                          : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF136E4D)
                            : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            const BoxShadow(
                              color: Color(0x33DC2626),
                              blurRadius: 8,
                              offset: Offset(0, 2),
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
                          isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trigger.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color:
                            isSelected ? Colors.white : const Color(0xFF374151),
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
