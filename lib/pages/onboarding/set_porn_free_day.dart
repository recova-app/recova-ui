import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/onboarding_state.dart';
import 'set-porn-free-day-result.dart';

class SetPornFreeDayPage extends StatefulWidget {
  const SetPornFreeDayPage({super.key});

  @override
  State<SetPornFreeDayPage> createState() => _SetPornFreeDayPageState();
}

class _SetPornFreeDayPageState extends State<SetPornFreeDayPage> {
  int selectedGoal = 1; // Default to "1 day (recommended)"
  final List<Map<String, dynamic>> goals = [
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
        builder: (context) => SetPornFreeDayResultPage(
          selectedGoal: selectedGoalText,
        ),
      ),
    );
  }

  void _skipForNow() {
    Navigator.pushNamed(context, '/set-checkin-time');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

              // Main instruction
              Text(
                'Mari mulai dengan target kecil untuk membangun momentum.',
                textAlign: TextAlign.center,
                style: AppText.h2.copyWith(
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  fontFamily: 'Inter',
                  color: const Color(0xFF1A1A1A),
                ),
              ),

              const SizedBox(height: AppSpacing.large * 2),

              // Goal Options
              Column(
                children: goals.asMap().entries.map((entry) {
                  final index = entry.key;
                  final goal = entry.value;
                  final isSelected = selectedGoal == index;
                  final isRecommended = goal['recommended'] as bool;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGoal = index;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.large),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF4CAF50).withOpacity(0.1)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFDDDDDD),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            goal['text'] as String,
                            style: AppText.body.copyWith(
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: isRecommended
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF1B5E20)
                                  : (isRecommended
                                      ? const Color(0xFF1A1A1A)
                                      : const Color(0xFF777777)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSpacing.large),

              // Set Goal Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _setGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Tetapkan target bebas pornografi',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }
}
