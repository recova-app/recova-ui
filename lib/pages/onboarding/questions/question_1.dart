import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/onboarding_state.dart';

class Question1 extends StatefulWidget {
  const Question1({super.key});

  @override
  State<Question1> createState() => _Question1State();
}

class _Question1State extends State<Question1> {
  String? selectedAnswer;
  final List<Map<String, String>> options = [
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
      OnboardingState().answers['Diumur berapa kamu menonton pornografi untuk pertama kalinya?'] = selectedAnswer;
      Navigator.pushNamed(context, '/question-2');
    }
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
                    widthFactor: 1 / 8, // Question 1 of 8
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

              // Question Label
              Text(
                'Pertanyaan 1',
                style: AppText.body.copyWith(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // Question Text
              Text(
                'Diumur berapa kamu menonton pornografi untuk pertama kalinya?',
                style: AppText.h2.copyWith(
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: AppSpacing.large * 2),

              // Answer Options
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedAnswer == option['value'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                      child: GestureDetector(
                        onTap: () => _selectAnswer(option['value']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.large,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4BB857).withOpacity(0.12)
                                : const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(AppRadius.large),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF4BB857),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Text(
                            option['text']!,
                            style: AppText.body.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : AppTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedAnswer != null ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAnswer != null
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFBDBDBD),
                    disabledBackgroundColor: const Color(0xFFBDBDBD),
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
