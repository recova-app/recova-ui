import 'package:flutter/material.dart';

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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF136E4D),
                    ),
                  ),
                  backgroundColor: const Color(0xFFEAF9F1),
                  side: const BorderSide(color: Color(0xFFD1FAE5)),
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
