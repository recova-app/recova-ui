import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import '../widgets/onboarding_button.dart';

class WhyCheckinPage extends StatelessWidget {
  const WhyCheckinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: ListView(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'assets/images/maskots/why-checkin.png',
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    fontFamily: 'Inter',
                    fontSize: 24,
                  ),
                  children: [
                    const TextSpan(text: 'Daily Checkin selama satu menit '),
                    TextSpan(
                      text: 'setiap hari',
                      style: TextStyle(
                        color: colorScheme.primary,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' akan membimbingmu untuk\nmembuat pilihan yang akan merubah hidupmu.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Mengapa check-in harian penting?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Membangun kesadaran diri adalah langkah pertama menuju pemulihan yang langgeng. Dengan check-in setiap hari, kamu memperkuat komitmenmu.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              OnboardingButton(
                text: 'Saya mengerti',
                onPressed: () {
                  Navigator.pushNamed(context, '/set-checkin-time');
                },
              ),
              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }
}
