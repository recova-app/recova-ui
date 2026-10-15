import 'package:flutter/material.dart';
import '../models/coach_persona.dart';

/// Floating persona selector displaying active persona and dropdown options
/// styled with dynamic [RecoveryTheme] tokens.
class CoachPersonaSelector extends StatelessWidget {
  final CoachPersona selectedPersona;
  final List<CoachPersona> personas;
  final bool isDropdownOpen;
  final VoidCallback onToggleDropdown;
  final ValueChanged<CoachPersona> onSelectPersona;
  final double avatarSize;

  const CoachPersonaSelector({
    super.key,
    required this.selectedPersona,
    required this.personas,
    required this.isDropdownOpen,
    required this.onToggleDropdown,
    required this.onSelectPersona,
    this.avatarSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final availablePersonas =
        personas.where((p) => p.key != selectedPersona.key).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        boxShadow:
            isDropdownOpen
                ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onToggleDropdown,
            child: Row(
              children: [
                Image.asset(
                  selectedPersona.avatarPath,
                  width: avatarSize,
                  height: avatarSize,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedPersona.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurface,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          if (isDropdownOpen) const SizedBox(height: 12),
          if (isDropdownOpen && availablePersonas.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color:
                    isDark
                        ? colorScheme.surfaceContainer
                        : colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children:
                    availablePersonas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final persona = entry.value;

                      return GestureDetector(
                        onTap: () => onSelectPersona(persona),
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 2,
                            right: 2,
                            top: index == 0 ? 2 : 0,
                            bottom:
                                index == availablePersonas.length - 1 ? 2 : 0,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: persona.backgroundColor(context),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                persona.avatarPath,
                                width: avatarSize,
                                height: avatarSize,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      persona.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: persona.textColor(context),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      persona.desc,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: persona
                                            .textColor(context)
                                            .withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
