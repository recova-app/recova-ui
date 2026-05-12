import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/onboarding_state.dart';

class SetNamePage extends StatefulWidget {
  const SetNamePage({super.key});

  @override
  State<SetNamePage> createState() => _SetNamePageState();
}

class _SetNamePageState extends State<SetNamePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateButtonState);
    _nameController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _nameController.text.trim().isNotEmpty;
    });
  }

  void _continue() {
    if (_nameController.text.trim().isNotEmpty) {
      OnboardingState().nickname = _nameController.text.trim();
      Navigator.pushNamed(context, '/question-1');
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
              // Main Content - Flexible instead of Expanded
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.large),

                      // Main Question Text
                      Text(
                        'Apa nama panggilan kamu?',
                        style: AppText.h2.copyWith(
                          fontFamily: 'Inter',
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.large * 2),

                      // Name Input Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Input Field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.medium),
                              border: Border.all(
                                color: const Color(0xFFDDDDDD),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _nameController,
                              style: AppText.body.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Siapa nama kamu?',
                                hintStyle: AppText.body.copyWith(
                                  color: const Color(0xFFBBBBBB),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.large,
                                  vertical: AppSpacing.medium,
                                ),
                              ),
                              onSubmitted: (_) => _continue(),
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(height: AppSpacing.large),

                      // Privacy Notice
                      Text(
                        'Hindari menyertakan informasi sensitif atau informasi yang membuatmu dapat dikenali oleh orang yang tidak kamu kenal.',
                        style: AppText.body.copyWith(
                          fontFamily: 'Inter',
                          color: const Color(0xFF777777),
                          height: 1.4,
                          fontSize: 16,
                        ),
                      ),

                      // Add some bottom spacing to ensure button is visible
                      const SizedBox(height: AppSpacing.large * 3),
                    ],
                  ),
                ),
              ),

              // Bottom Button - Fixed at bottom
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isButtonEnabled
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFBDBDBD),
                    disabledBackgroundColor: const Color(0xFFBDBDBD),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    'Lanjutkan',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _isButtonEnabled ? Colors.white : const Color(0xFF777777),
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
