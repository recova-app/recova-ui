import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/services/onboarding_state.dart';
import '../../widgets/onboarding_button.dart';
import '../../widgets/onboarding_option_tile.dart';
import '../../widgets/onboarding_progress_bar.dart';

class Question3 extends StatefulWidget {
  const Question3({super.key});

  @override
  State<Question3> createState() => _Question3State();
}

class _Question3State extends State<Question3> {
  int? selectedOption;
  final List<String> options = const [
    'Lebih dari sekali sehari',
    'Sekali sehari',
    'Beberapa kali seminggu',
    'Kurang dari sekali seminggu',
  ];

  void _selectOption(int index) {
    setState(() {
      selectedOption = index;
    });
  }

  void _continue() {
    if (selectedOption != null) {
      OnboardingState().answers['Seberapa sering kamu menonton pornografi?'] =
          options[selectedOption!];
      Navigator.pushNamed(context, '/question-4');
    }
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
              OnboardingProgressBar.step(currentStep: 3, totalSteps: 9),
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
                'Pertanyaan 3',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Seberapa sering kamu menonton pornografi?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.large * 2),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedOption == index;
                    return OnboardingOptionTile(
                      text: options[index],
                      isSelected: isSelected,
                      onTap: () => _selectOption(index),
                    );
                  },
                ),
              ),
              OnboardingButton(
                text: 'Continue',
                isEnabled: selectedOption != null,
                onPressed: _continue,
              ),
              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }
}
