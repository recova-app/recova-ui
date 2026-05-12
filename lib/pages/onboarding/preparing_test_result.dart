import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/onboarding_state.dart';

class PreparingTestResultPage extends StatefulWidget {
  const PreparingTestResultPage({super.key});

  @override
  State<PreparingTestResultPage> createState() =>
      _PreparingTestResultPageState();
}

class _PreparingTestResultPageState extends State<PreparingTestResultPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Animation for brain rotation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Animation for progress bar
    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 0.98, // 24% as shown in the design
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    // Start animations
    _animationController.repeat(reverse: true);
    _progressController.forward();

    // Submit data to API and navigate to results
    _submitOnboardingData();
  }

  Future<void> _submitOnboardingData() async {
    try {
      final authService = AuthService();
      final data = OnboardingState().toJson();
      await authService.submitOnboarding(data);
    } catch (e) {
      print('Error submitting onboarding data: $e');
    } finally {
      // Ensure we navigate after at least 4 seconds for the animation
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/results');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Content
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                  width: 200,
                                  height: 200,
                                  child: Image.asset(
                                    'assets/images/maskots/preparing-results.png',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                            ],
                          ),
                        ),

                    const SizedBox(height: AppSpacing.large),

                    // Title
                    Text(
                      'Tahukah kamu?',
                      style: AppText.h2.copyWith(
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        fontFamily: 'Inter',
                      ),
                    ),

                    const SizedBox(height: AppSpacing.large),

                    // Main message
                    Text(
                      'Pornografi membajak sistem reward di otak kamu, menjebakmu dalam siklus yang tak berujung',
                      textAlign: TextAlign.center,
                      style: AppText.h2.copyWith(
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Progress Section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Progress Bar
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                          children: [
                            // Progress bar
                            Container(
                              width: double.infinity,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.medium),

                            // Progress text
                            Text(
                              'Mempersiapkan hasilmu...${(_progressAnimation.value * 100).toInt()}%',
                              style: AppText.body.copyWith(
                                color: const Color(0xFF777777),
                                fontSize: 16,
                                fontFamily: 'Inter',
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
