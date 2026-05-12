import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Learning1 extends StatelessWidget {
  const Learning1({super.key});

  @override
  Widget build(BuildContext context) {
    print('Learning1 build method called'); // Debug print
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            children: [
              // Main Content Area - Scrollable to prevent overflow
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.large), // Top spacing
                      Container(
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

                      // Main Question Text
                      Text(
                        'Mengapa Saya Menonton Begitu Banyak Pornografi?',
                        textAlign: TextAlign.center,
                        style: AppText.h2.copyWith(
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.medium),

                      // Subtitle
                      Text(
                        'Mari kita pelajari bersama tentang dampakdan cara mengatasi kecanduan pornografi',
                        textAlign: TextAlign.center,
                        style: AppText.body.copyWith(
                          color: AppTheme.textGrey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.large), // Bottom spacing
                    ],
                  ),
                ),
              ),

              // Bottom Action Area - Always visible and clickable
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.medium, bottom: AppSpacing.medium),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/learning-2');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Selanjutnya',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
