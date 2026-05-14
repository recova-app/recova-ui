import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/onboarding_state.dart';

class Question2 extends StatefulWidget {
  const Question2({super.key});

  @override
  State<Question2> createState() => _Question2State();
}

class _Question2State extends State<Question2> {
  int selectedAge = 15;
  final List<int> ages = [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50];

  void _continue() {
    OnboardingState().answers['Berapa umur kamu sekarang?'] = selectedAge;
    Navigator.pushNamed(context, '/question-3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 16,
                  color: const Color(0xFFE0E0E0),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 2 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BB857),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.large),

              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF9E9E9E),
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // Question Label
              Text(
                'Pertanyaan 2',
                style: AppText.body.copyWith(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // Question Text
              Text(
                'Berapa umur kamu sekarang?',
                style: AppText.h2.copyWith(
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),

              // Age Picker
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 300,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 60,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedAge = ages[index];
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index >= ages.length) return null;

                          final age = ages[index];
                          final isSelected = age == selectedAge;

                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: isSelected
                                  ? Border(
                                      top: BorderSide(
                                          color: const Color(0xFF4BB857)
                                              .withOpacity(0.4)),
                                      bottom: BorderSide(
                                          color: const Color(0xFF4BB857)
                                              .withOpacity(0.4)),
                                    )
                                  : null,
                            ),
                            child: Text(
                              age.toString(),
                              style: TextStyle(
                                fontSize: isSelected ? 32 : 24,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF2E7D32)
                                    : AppTheme.textGrey,
                              ),
                            ),
                          );
                        },
                        childCount: ages.length,
                      ),
                    ),
                  ),
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
