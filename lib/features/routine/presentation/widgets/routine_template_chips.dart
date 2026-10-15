import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

class RoutineTemplateChips extends StatelessWidget {
  final List<String> templates;
  final bool isEnabled;
  final TextEditingController controller;

  const RoutineTemplateChips({
    super.key,
    required this.templates,
    required this.isEnabled,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            templates.map((template) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(
                    template,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  backgroundColor: recoveryTheme.accentSurface,
                  side: BorderSide(color: colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed:
                      isEnabled
                          ? () {
                            if (controller.text.isEmpty) {
                              controller.text = template;
                            } else {
                              controller.text = '${controller.text} $template';
                            }
                          }
                          : null,
                ),
              );
            }).toList(),
      ),
    );
  }
}
