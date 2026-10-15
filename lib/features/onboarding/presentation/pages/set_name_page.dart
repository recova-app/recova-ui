import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/services/onboarding_state.dart';
import '../widgets/onboarding_button.dart';

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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        'Apa nama panggilan kamu?',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.large * 2),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Siapa nama kamu?',
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.6,
                              ),
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
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        'Hindari menyertakan informasi sensitif atau informasi yang membuatmu dapat dikenali oleh orang yang tidak kamu kenal.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.large * 3),
                    ],
                  ),
                ),
              ),
              OnboardingButton(
                text: 'Lanjutkan',
                isEnabled: _isButtonEnabled,
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
