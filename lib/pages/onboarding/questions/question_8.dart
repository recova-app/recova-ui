import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/onboarding_state.dart';

class Question8 extends StatefulWidget {
  const Question8({super.key});

  @override
  State<Question8> createState() => _Question8State();
}

class _Question8State extends State<Question8> {
  int? selectedOption;
  final List<String> options = [
    'Ya',
    'Tidak',
  ];

  void _selectOption(int index) {
    setState(() {
      selectedOption = index;
    });
  }

  void _continue() {
    if (selectedOption != null) {
      Navigator.pushNamed(context, '/question-9');
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
                    widthFactor: 8 / 9,
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
                'Pertanyaan 8',
                style: AppText.body.copyWith(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // Question Text
              Text(
                'Apakah kamu menonton pornografi untuk menghindari perasaan sakit?',
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
                    final isSelected = selectedOption == index;

                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.medium),
                      child: GestureDetector(
                        onTap: () => _selectOption(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.large,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4BB857).withOpacity(0.12)
                                : const Color(0xFFF2F2F2),
                            borderRadius:
                                BorderRadius.circular(AppRadius.large),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF4BB857),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Text(
                            options[index],
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
                  onPressed: selectedOption != null ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedOption != null
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
