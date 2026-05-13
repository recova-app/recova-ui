import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/checkin_cubit.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/pages/checkin_page.dart';
import 'package:recova/pages/emergency_page.dart';
import 'package:recova/pages/login_page.dart';
import 'package:recova/services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  bool _hasCheckedInToday(Statistics stats) {
    if (stats.streakCalendar.isEmpty) return false;
    final last = DateTime.parse(stats.streakCalendar.last);
    final now = DateTime.now();
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final user = User(
      id: '1',
      email: 'alex@example.com',
      nickname: 'Alex',
      userWhy: null,
      checkinTime: '18:00',
      createdAt: DateTime.now(),
    );
    final stats = Statistics(
      currentStreak: 23,
      longestStreak: 23,
      totalCheckins: 23,
      streakCalendar: const [],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
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
                IconButton(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Halo, ${user.nickname}! 👋', style: const TextStyle(fontSize: 48 * 0.8, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4 ),
            const Text('Proud of you for showing up today', style: TextStyle(fontSize: 34 * 0.42, color: Color(0xFF8B98A0))),
            const SizedBox(height: 18),
            _StreakCard(currentStreak: stats.currentStreak, progress: (stats.currentStreak / 32).clamp(0.0, 1.0)),
            const SizedBox(height: 24),
            const Text('Daily Routine', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final checkinCubit = context.read<CheckinCubit>();
                final messenger = ScaffoldMessenger.of(context);
                checkinCubit.resetState();
                final result = await Navigator.push<CheckinState?>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckInPage(
                      streakDays: stats.currentStreak,
                      hasCheckedInToday: _hasCheckedInToday(stats),
                    ),
                  ),
                );
                if (result is CheckinSuccess) {
                  messenger.showSnackBar(const SnackBar(content: Text('Check-in berhasil!'), backgroundColor: Colors.green));
                } else if (result is CheckinFailure) {
                  messenger.showSnackBar(SnackBar(content: Text('Gagal check-in: ${result.error}'), backgroundColor: Colors.red));
                }
              },
              child: const _FeatureCard(
                title: 'Check-In Harian Diatur Saat 6pm',
                subtitle: 'Klik untuk Check-In lebih awal',
                assetPath: 'assets/images/home/icon_checkin.png',
                bg: Color(0xFFEAF9F1),
                arrow: true,
              ),
            ),
            const SizedBox(height: 12),
            const _FeatureCard(
              title: 'Relapse',
              subtitle: 'Akui, evaluasi, dan reset progress kamu.',
              assetPath: 'assets/images/home/icon_motivation.png',
              bg: Color(0xFFF19598),
              titleColor: Colors.white,
              subtitleColor: Color(0xFFFFEDEE),
            ),
            const SizedBox(height: 12),
            const _FeatureCard(
              title: 'Daily Activity Challenge',
              subtitle: 'Dapatkan Tantangan harian untuk mengatasi rasa bosanmu',
              assetPath: 'assets/images/home/icon_challenge.png',
              bg: Color(0xFFE5E5E5),
            ),
            const SizedBox(height: 26),
            const Text('Bantu Pemulihan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            _FeatureCard(
              title: 'Emergency Button',
              subtitle: 'Dapatkan Bantuan instan ketika dalam waktu feeling tempted',
              assetPath: 'assets/images/home/icon_emergency.png',
              bg: const Color(0xFFE3E3E3),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyPage(), fullscreenDialog: true));
              },
            ),
            const SizedBox(height: 12),
            const _FeatureCard(
              title: 'Smart Personal AI Coach',
              subtitle: 'Dapatkan Insight untuk Keluhan atau Pertanyaanmu',
              assetPath: 'assets/images/home/icon_coach.png',
              bg: Color(0xFFE3E3E3),
            ),
            const SizedBox(height: 26),
            const Text('Today Insight', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              decoration: BoxDecoration(color: const Color(0xFFE3E3E3), borderRadius: BorderRadius.circular(12)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Kamu sudah melakukan yang terbaik hari ini, hasil yang memuaskan datang dari hal kecil yang dilakukan secara konsisten.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.25)),
                SizedBox(height: 16),
                Text('Insight ini disesuaikan dari journal harian yang kamu tulis dan aktivitas daily check-in kamu',
                    style: TextStyle(fontSize: 10, color: Color(0xFF7A7A7A))),
              ]),
            )
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.bg,
    this.arrow = false,
    this.onTap,
    this.titleColor = const Color(0xFF111111),
    this.subtitleColor = const Color(0xFF454545),
  });
  final String title;
  final String subtitle;
  final String assetPath;
  final Color bg;
  final bool arrow;
  final VoidCallback? onTap;
  final Color titleColor;
  final Color subtitleColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Image.asset(assetPath, width: 26, height: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 31 * 0.42, color: titleColor)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 21 * 0.42, color: subtitleColor)),
            ]),
          ),
          if (arrow) const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.currentStreak, required this.progress});
  final int currentStreak;
  final double progress;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF136E4D), // Background utama diubah menjadi hijau agar lengkungan putih terlihat
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(children: [
        Stack(
          clipBehavior: Clip.none, // Mengizinkan elemen meluap dari batas
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 140, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Streak Kamu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text('$currentStreak Hari', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 40)),
                  const SizedBox(height: 2),
                  const Text(
                    'Setelah Melakukan Daily Check-in streak\nkamu akan terupdate di tengah malam',
                    style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 8, height: 1.3),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: -30,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(18)),
                child: Image.asset(
                  'assets/images/home/gunung.png',
                  width: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18), // Melengkungkan container putih seperti gambar
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final isLast = index == 6;
                return Column(
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
                        color: isLast ? const Color(0xFF111111) : const Color(0xFF8B98A0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isLast)
                      Container(
                        width: 28,
                        height: 28,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF38B768), width: 1.5),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFD1E8CD),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Color(0xFF9ECEAA), size: 16),
                        ),
                      )
                    else
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(color: Color(0xFF38B768), shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Progress: 11 / 32 Days',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38B768)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
