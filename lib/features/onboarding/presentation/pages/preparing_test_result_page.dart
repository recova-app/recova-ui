import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/services/auth_service.dart';
import 'package:recova/services/onboarding_state.dart';

class PreparingTestResultPage extends StatefulWidget {
  const PreparingTestResultPage({super.key});

  @override
  State<PreparingTestResultPage> createState() =>
      _PreparingTestResultPageState();
}

class _PreparingTestResultPageState extends State<PreparingTestResultPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  Map<String, dynamic>? _onboardingResult;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 0.98).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _progressController.forward();
    _submitOnboardingData();
  }

  Future<void> _submitOnboardingData() async {
    try {
      final authService = AuthService();
      final data = OnboardingState().toJson();
      _onboardingResult = await authService.submitOnboarding(data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error submitting onboarding data: $e');
      }
    } finally {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/results',
          arguments: _onboardingResult,
        );
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Image.asset(
                          'assets/images/maskots/preparing-results.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      'Tahukah kamu?',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      'Pornografi membajak sistem reward di otak kamu, menjebakmu dalam siklus yang tak berujung',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withOpacity(0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            Text(
                              'Mempersiapkan hasilmu...${(_progressAnimation.value * 100).toInt()}%',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.large),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
