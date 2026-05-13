import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recova/pages/main_scaffold.dart';
import 'package:recova/pages/login_page.dart';
import 'package:recova/pages/onboarding/set_name.dart';
import 'package:recova/services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait 3 seconds for splash screen effect
    await Future.delayed(const Duration(seconds: 5));

    final AuthService authService = AuthService();
    final String? token = await authService.getToken();

    if (!mounted) return;

    Widget page;
    if (token == null) {
      page = const LoginPage();
    } else {
      // Token exists – check if onboarding was completed
      final onboarded = await authService.isOnboardingCompleted();
      // page = onboarded ? const MainScaffold() : const SetNamePage();
      page =  const MainScaffold();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top content ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo icon – centred
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 64,
                      height: 64,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // "You're not your past."
                  const Text(
                    "You're not\nyour past.",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                      height: 1.15,
                    ),
                  ),

                  // "You're building your future."
                  const Text(
                    "You're building\nyour future.",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4CAF50),
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Yellow accent line
                  Container(
                    width: 56,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5A623),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subtitle
                  const Text(
                    "Track your progress. get support\nwhen you need it. Build life that sets\nyou free",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF555555),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // ── Character image – fills remaining space ───────────────────
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/billy-on-splash.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
