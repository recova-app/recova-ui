import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WhyCheckinPage extends StatelessWidget {
  const WhyCheckinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: ListView(
            children: [
              // Tombol kembali di bagian atas
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF777777),
                      size: 20,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Gambar utama
              Container(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/maskots/why-checkin.png',
                  width: 220,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 60),

              // Teks utama
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppText.h2.copyWith(
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    fontFamily: 'Inter',
                  ),
                  children: [
                    const TextSpan(text: 'Daily Checkin selama satu menit '),
                    TextSpan(
                      text: 'setiap hari',
                      style: AppText.h2.copyWith(
                        color: const Color(0xFF4CAF50),
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

              const SizedBox(height: 60),

              // Teks manfaat
              Text(
                'Kebanyakan pengguna mulai merasakan manfaatnya dalam minggu pertama.',
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  color: const Color(0xFF777777),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // Tombol "Atur Waktu Check-in"
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/set-checkin-time');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Atur Waktu Check-in',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // Tombol "Atur Waktu Check-in"
              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }
}
