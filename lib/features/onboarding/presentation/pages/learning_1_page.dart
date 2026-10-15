import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import '../widgets/onboarding_button.dart';

class Learning1 extends StatelessWidget {
  const Learning1({super.key});

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
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.large),
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Image.asset(
                          'assets/images/maskots/learning-1.png',
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        'Mengapa Saya Menonton Begitu Banyak Pornografi?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        'Mari kita pelajari bersama tentang dampakdan cara mengatasi kecanduan pornografi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.large),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.medium,
                  bottom: AppSpacing.medium,
                ),
                child: OnboardingButton(
                  text: 'Selanjutnya',
                  onPressed: () {
                    Navigator.pushNamed(context, '/learning-2');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
