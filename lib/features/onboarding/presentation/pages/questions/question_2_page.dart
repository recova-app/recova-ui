import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/services/onboarding_state.dart';
import '../../widgets/onboarding_button.dart';
import '../../widgets/onboarding_progress_bar.dart';

class Question2 extends StatefulWidget {
  const Question2({super.key});

  @override
  State<Question2> createState() => _Question2State();
}

class _Question2State extends State<Question2> {
  int selectedAge = 15;
  late final FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: ages.indexOf(selectedAge));

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<int> ages = const [
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
  ];

  void _continue() {
    OnboardingState().answers['Berapa umur kamu sekarang?'] = selectedAge;
    Navigator.pushNamed(context, '/question-3');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OnboardingProgressBar.step(currentStep: 2, totalSteps: 9),
              const SizedBox(height: AppSpacing.large),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Pertanyaan 2',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Berapa umur kamu sekarang?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: colorScheme.onSurface,
                ),
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 300,
                    child: ListWheelScrollView.useDelegate(
                      controller: _scrollController,
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
                              border:
                                  isSelected
                                      ? Border(
                                        top: BorderSide(
                                          color: colorScheme.primary
                                              .withOpacity(0.4),
                                        ),
                                        bottom: BorderSide(
                                          color: colorScheme.primary
                                              .withOpacity(0.4),
                                        ),
                                      )
                                      : null,
                            ),
                            child: Text(
                              age.toString(),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: isSelected ? 32 : 24,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
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
              OnboardingButton(text: 'Continue', onPressed: _continue),
              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }
}
