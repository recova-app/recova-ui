import 'package:flutter/material.dart';
import 'package:recova/pages/main_scaffold.dart';
import 'package:recova/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final AuthService _authService = AuthService();

  String get _loginButtonLabel {
    if (isLoading) return 'Memproses...';
    return AuthService.useMockMode ? 'Masuk Demo' : 'Lanjutkan Dengan Google';
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      final token = await _authService.signInWithGoogle();
      if (!mounted) return;

      if (token != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScaffold()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Terjadi kesalahan saat login. Silakan coba lagi.';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CA7A3), // hijau tosca muda
              Color(0xFF1E3A3A), // hijau tosca gelap
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: height * 0.12),

                // 🔹 Logo di tengah atas
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 108,
                    height: 108,
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.24),
                    ),
                  ),
                  child: const Text(
                    'Mode demo aktif: data tampil statik sementara',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 🔹 Teks kutipan motivasi
                const Text(
                  "“Kamu telah mengambil langkah terberat. Perjalananmu menuju kebebasan dimulai dari sini”",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                ),

                SizedBox(height: height * 0.1),

                // 🔹 Judul Masuk / Daftar
                const Text(
                  "Masuk / Daftar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),

                // 🔹 Deskripsi data aman
                const Text(
                  "Data kamu aman bersama kami.\nKami hanya menyimpan profil dan aktivitas akun kamu",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 40),

                // 🔹 Tombol Google
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 4,
                    ),
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Image.asset(
                        'assets/images/google.png',
                        height: 26,
                      ),
                    ),
                    label: Text(
                      _loginButtonLabel,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
