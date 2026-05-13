import 'package:flutter/material.dart';

class CommunityHubPage extends StatelessWidget {
  const CommunityHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.star, size: 16),
                  ),
                  const Icon(Icons.notifications_none_rounded),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 172,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C7A57),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      left: 18,
                      top: 24,
                      right: 135,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kamu tidak berjuang sendirian',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 38 * 0.55,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'dapatkan bantuan dari teman seperjuangan di komunitas, atau bantuan dari ai coach kami',
                            style: TextStyle(
                              color: Color(0xFFD1FAE5),
                              fontSize: 9,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: -5,
                      bottom: 0,
                      child: Image.asset(
                        'assets/images/home/headHub.png',
                        width: 140,
                        height: 140,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _MenuCard(
                title: 'Chat Dengan Billy',
                subtitle: 'Billy Merupakan Ai companion yang akan menjawab semua keresahan kamu',
                assetPath: 'assets/images/home/billy.png',
                imageWidth: 70, // Atur ukuran lebar gambar billy di sini
                imageHeight: 70, // Atur ukuran tinggi gambar billy di sini
                // Atur posisi gambar billy (geser X dan Y) di sini
                imageOffset: const Offset(-5, 0), 
              ),
              const SizedBox(height: 14),
              _MenuCard(
                title: 'Temukan Komunitas',
                subtitle: 'temukan teman seperjuangan di komunitas',
                assetPath: 'assets/images/home/community.png',
                imageWidth: 70, // Atur ukuran lebar gambar billy di sini
                imageHeight: 70, // Atur ukuran tinggi gambar billy di sini
                // Atur posisi gambar billy (geser X dan Y) di sini
                imageOffset: const Offset(0, 0), 
              ),
              // const SizedBox(height: 14),
              // const _MenuCard(
              //   title: 'Konsultasi Dengan Ahli',
              //   subtitle: 'konsultasi secara gratis maupun berbayar dengan ahli',
              //   assetPath: 'assets/images/home/icon_emergency.png',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    this.imageWidth = 56,
    this.imageHeight = 56,
    this.imageOffset = Offset.zero,
  });

  final String title;
  final String subtitle;
  final String assetPath;
  final double imageWidth;
  final double imageHeight;
  final Offset imageOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE8E2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Transform.translate(
            offset: imageOffset,
            child: Image.asset(
              assetPath, 
              width: imageWidth, 
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 48 * 0.42,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF2F2F2F),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
