import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/services/onboarding_state.dart';
import '../../widgets/onboarding_button.dart';
import '../../widgets/onboarding_option_tile.dart';
import '../../widgets/onboarding_progress_bar.dart';

class Question1 extends StatefulWidget {
  const Question1({super.key});

  @override
  State<Question1> createState() => _Question1State();
}

class _Question1State extends State<Question1> {
  String? selectedAnswer;
  final List<Map<String, String>> options = const [
    {'text': '12 tahun atau lebih muda', 'value': '12_or_younger'},
    {'text': '13 sampai 16 tahun', 'value': '13_to_16'},
    {'text': '17 sampai 24 tahun', 'value': '17_to_24'},
    {'text': '25 tahun atau lebih tua', 'value': '25_or_older'},
  ];

  void _selectAnswer(String value) {
    setState(() {
      selectedAnswer = value;
    });
  }

  void _continue() {
    if (selectedAnswer != null) {
      OnboardingState()
              .answers['Diumur berapa kamu menonton pornografi untuk pertama kalinya?'] =
          selectedAnswer;
      Navigator.pushNamed(context, '/question-2');
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
              OnboardingProgressBar.step(currentStep: 1, totalSteps: 9),
              const SizedBox(height: AppSpacing.large),
              Text(
                'Pertanyaan 1',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Diumur berapa kamu menonton pornografi untuk pertama kalinya?',
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
                    final option = options[index];
                    final isSelected = selectedAnswer == option['value'];

                    return OnboardingOptionTile(
                      text: option['text']!,
                      isSelected: isSelected,
                      onTap: () => _selectAnswer(option['value']!),
                    );
                  },
                ),
              ),
              OnboardingButton(
                text: 'Continue',
                isEnabled: selectedAnswer != null,
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
