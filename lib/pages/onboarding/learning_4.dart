import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Learning4 extends StatelessWidget {
  const Learning4({super.key});

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
              // Brain with Double Syringes Illustration and Main Content
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Container(
                      width: 220,
                      height: 220,
                      child: Image.asset(
                        'assets/images/maskots/learning-4.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.large),

                    // Main Title
                    Text(
                      'Saya butuh lebih banyak',
                      textAlign: TextAlign.center,
                      style: AppText.h2.copyWith(
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.medium),

                    // Description
                    Text(
                      'Semakin banyak pornografi yang kamu tonton, semakin banyak dopamin yang dibutuhkan otak kamu untuk merasa baik. Inilah sebabnya pornografi tidak memuaskanmu seperti dulu.',
                      textAlign: TextAlign.center,
                      style: AppText.body.copyWith(
                        color: AppTheme.textGrey,
                        height: 1.4,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Navigation Area
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Navigation Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFDDDDDD),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xFF777777),
                              size: 20,
                            ),
                          ),
                        ),

                        // Next Button
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B5E20),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Navigate to next learning page or complete learning
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/learning-5',
                                (route) => false,
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.medium),
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
