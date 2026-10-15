import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recova/pages/main_scaffold.dart';
import 'package:recova/features/onboarding/presentation/pages/learning_1_page.dart';
import 'package:recova/services/auth_service.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_validation_banner.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isEmailLoading = false;
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateAfterAuth(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>? ?? {};
    final onboardingCompleted = user['onboarding_completed'] as bool? ?? false;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                onboardingCompleted ? const MainScaffold() : const Learning1(),
      ),
    );
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isEmailLoading = true);

    try {
      final data = await _authService.loginWithEmail(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      _navigateAfterAuth(data);
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      AuthValidationBanner.showErrorSnackBar(context, errorMessage);
      if (kDebugMode) {
        debugPrint('Auth login error: $errorMessage');
      }
    } finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AuthScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const AuthHeader(
                      title: 'Masuk',
                      subtitle:
                          'Data kamu aman bersama kami. Kami hanya menyimpan profil dan aktivitas akun kamu',
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _identifierController,
                      hint: 'Email atau username',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email atau username wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AuthTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    AuthButton(
                      text: 'Masuk',
                      onPressed: _handleEmailLogin,
                      isLoading: _isEmailLoading,
                      borderRadius: 12,
                      height: 52,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Daftar',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
