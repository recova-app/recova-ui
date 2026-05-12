import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Learning2 extends StatelessWidget {
  const Learning2({super.key});

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
              // Ilustrasi Otak dengan Suntikan dan Konten Utama
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ilustrasi Otak dengan Suntikan
                    Container(
                      width: 220,
                      height: 220,
                      child: Image.asset(
                        'assets/images/maskots/learning-2.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.large),

                    // Main Title
                    Text(
                      'Pornografi adalah obat',
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
                      'Menonton pornografi melepaskan zat kimia di otak yang disebut dopamin. Zat kimia ini membuatmu merasa senang. inilah alasan mengapa kamu merasa nikmat saat menonton pornografi.',
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

              // Area Navigasi Bawah
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Baris Navigasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol Kembali
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

                        // Tombol Selanjutnya
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B5E20),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Pindah ke halaman pembelajaran berikutnya
                              Navigator.pushNamed(context, '/learning-3');
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
