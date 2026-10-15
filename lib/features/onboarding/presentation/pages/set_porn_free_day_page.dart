import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/services/onboarding_state.dart';
import '../widgets/onboarding_button.dart';
import 'set_porn_free_day_result_page.dart';

class SetPornFreeDayPage extends StatefulWidget {
  const SetPornFreeDayPage({super.key});

  @override
  State<SetPornFreeDayPage> createState() => _SetPornFreeDayPageState();
}

class _SetPornFreeDayPageState extends State<SetPornFreeDayPage> {
  int selectedGoal = 1; // Default to "14 hari (recommended)"
  final List<Map<String, dynamic>> goals = const [
    {'text': '7 hari', 'value': 7, 'recommended': false},
    {'text': '14 hari', 'value': 14, 'recommended': true},
    {'text': '30 hari', 'value': 30, 'recommended': false},
    {'text': '69 hari', 'value': 69, 'recommended': false},
  ];

  void _setGoal() {
    final selectedGoalText = goals[selectedGoal]['text'] as String;
    final selectedGoalValue = goals[selectedGoal]['value'] as int;

    OnboardingState().pornFreeGoal = selectedGoalValue;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                SetPornFreeDayResultPage(selectedGoal: selectedGoalText),
      ),
    );
  }

  void _skipForNow() {
    Navigator.pushNamed(context, '/set-checkin-time');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.large),
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/maskots/set-porn-free-day.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              Text(
                'Mari mulai dengan target kecil untuk membangun momentum.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.large),
              Column(
                children:
                    goals.asMap().entries.map((entry) {
                      final index = entry.key;
                      final goal = entry.value;
                      final isSelected = selectedGoal == index;
                      final isRecommended = goal['recommended'] as bool;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGoal = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? colorScheme.primary.withOpacity(0.12)
                                      : colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline.withOpacity(0.4),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  goal['text'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                    color:
                                        isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                  ),
                                ),
                                if (isRecommended)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Rekomendasi',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: AppSpacing.large),
              OnboardingButton(text: 'Targetkan', onPressed: _setGoal),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _skipForNow,
                  child: Text(
                    'Lewati Sekarang',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
