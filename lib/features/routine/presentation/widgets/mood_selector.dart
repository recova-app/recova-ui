import 'package:flutter/material.dart';

class MoodOption {
  final String emoji;
  final String label;
  final String value;

  const MoodOption({
    required this.emoji,
    required this.label,
    required this.value,
  });
}

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String>? onMoodSelected;
  final bool isEnabled;
  final Color activeColor;
  final List<MoodOption> moods;

  static const List<MoodOption> defaultMoods = [
    MoodOption(emoji: '😢', label: 'Sangat Buruk', value: 'sangat_buruk'),
    MoodOption(emoji: '😟', label: 'Buruk', value: 'buruk'),
    MoodOption(emoji: '😐', label: 'Biasa', value: 'biasa'),
    MoodOption(emoji: '😊', label: 'Baik', value: 'baik'),
    MoodOption(emoji: '🤩', label: 'Sangat Baik', value: 'sangat_baik'),
  ];

  const MoodSelector({
    super.key,
    required this.selectedMood,
    this.onMoodSelected,
    this.isEnabled = true,
    this.activeColor = const Color(0xFF38B768),
    this.moods = defaultMoods,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF9F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            moods.map((mood) {
              final isSelected = selectedMood == mood.value;
              return GestureDetector(
                onTap:
                    isEnabled ? () => onMoodSelected?.call(mood.value) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: activeColor.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.25 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mood.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
