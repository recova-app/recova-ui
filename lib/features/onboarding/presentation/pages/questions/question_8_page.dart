import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/services/onboarding_state.dart';
import '../../widgets/onboarding_button.dart';
import '../../widgets/onboarding_option_tile.dart';
import '../../widgets/onboarding_progress_bar.dart';

class Question8 extends StatefulWidget {
  const Question8({super.key});

  @override
  State<Question8> createState() => _Question8State();
}

class _Question8State extends State<Question8> {
  int? selectedOption;
  final List<String> options = const ['Ya', 'Tidak'];

  void _selectOption(int index) {
    setState(() {
      selectedOption = index;
    });
  }

  void _continue() {
    if (selectedOption != null) {
      OnboardingState()
              .answers['Apakah kamu menonton pornografi untuk menghindari perasaan sakit?'] =
          options[selectedOption!];
      Navigator.pushNamed(context, '/question-9');
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
              OnboardingProgressBar.step(currentStep: 8, totalSteps: 9),
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
                'Pertanyaan 8',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Apakah kamu menonton pornografi untuk menghindari perasaan sakit?',
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
