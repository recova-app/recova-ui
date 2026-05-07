import 'package:flutter/material.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4573D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header bar dengan tombol close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Emergency",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    // Ganti 'assets/images/close.png' dengan path gambar Anda
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              const Text(
                "Kamu merasa tergoda? coba salah satu dari hal ini",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Aksi
              _buildActionButton(
                iconAsset: "assets/images/home/icon_review.png", // Placeholder
                label: "Review Manifesto Yang Kamu Tulis",
                onTap: () {},
              ),
              const SizedBox(height: 16),

              _buildActionButton(
                iconAsset: "assets/images/home/icon_exercise.png", // Placeholder
                label: "Lakukan latihan fisik sederhana",
                onTap: () {},
              ),
              const SizedBox(height: 16),

              _buildActionButton(
                iconAsset: "assets/images/home/icon_pencil.png", // Placeholder
                label: "Tulis Apa yang kamu rasakan sekarang",
                onTap: () {},
              ),
              const SizedBox(height: 16),

              _buildActionButton(
                iconAsset: "assets/images/home/icon_pencil.png", // Placeholder
                label: "Baca Artikel Atau Lihat Video Edukasi",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String iconAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Image.asset(
              iconAsset,
              color: Colors.white,
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}