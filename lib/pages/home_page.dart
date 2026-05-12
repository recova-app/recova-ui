import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/checkin_cubit.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/pages/checkin_page.dart';
import 'package:recova/pages/emergency_page.dart';
import 'package:recova/pages/login_page.dart';
import 'package:recova/services/api_service.dart';
import 'package:recova/services/auth_service.dart';
import 'package:recova/widgets/recova_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _homeCubit;
  late final CheckinCubit _checkinCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = context.read<HomeCubit>();
    _checkinCubit = context.read<CheckinCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeCubit.fetchHomeData();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();

    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  bool _hasCheckedInToday(Statistics? stats) {
    if (stats == null || stats.streakCalendar.isEmpty) {
      return false;
    }

    final lastCheckInDate = DateTime.parse(stats.streakCalendar.last);
    final now = DateTime.now();

    return lastCheckInDate.year == now.year &&
        lastCheckInDate.month == now.month &&
        lastCheckInDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {

        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeLoadFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFD65A5A),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gagal memuat data: ${state.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _homeCubit.fetchHomeData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E6B52),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! HomeLoadSuccess) {
          return const SizedBox.shrink();
        }

        final user = state.user;
        final stats = state.statistics;
        final hasCheckedInToday = _hasCheckedInToday(stats);
        const totalDays = 32;

        return RefreshIndicator(
          onRefresh: _homeCubit.fetchHomeData,
          color: const Color(0xFF0E6B52),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecovaTopBar(
                    onLeftPressed: () => _handleLogout(context),
                    onRightPressed: () {},
                    leftIcon: Icons.settings,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Halo, ${user.nickname}! 👋',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Proud of you for showing up today',
                    style: TextStyle(fontSize: 16, color: Color(0xFF8B98A0)),
                  ),
                  const SizedBox(height: 18),
                  RecovaHeroBanner(
                    title: 'Streak Kamu\n${stats.currentStreak} Hari',
                    subtitle:
                        'Setelah melakukan daily check-in streak kamu akan terupdate di tengah malam',
                    imagePath: 'assets/images/home/gunung.png',
                    height: 140,
                    imageWidth: 130,
                    contentPadding: const EdgeInsets.fromLTRB(20, 20, 14, 18),
                    footer: _buildWeekFooter(stats, totalDays),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Daily Routine',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  RecovaFeatureCard(
                    onTap:
                        () => _openCheckIn(stats, hasCheckedInToday, context),
                    title:
                        'Check-In Harian Diatur Saat ${_formatCheckInTime(user.checkinTime)}',
                    subtitle: 'Klik untuk Check-In lebih awal',
                    assetPath: 'assets/images/home/icon_checkin.png',
                    backgroundColor: const Color(0xFFEAF9F1),
                    iconBackground: Colors.white,
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const RecovaFeatureCard(
                    title: 'Motivation',
                    subtitle:
                        'Dapatkan Motivasi Untuk tetap terus di jalan yang benar',
                    assetPath: 'assets/images/home/icon_motivation.png',
                    backgroundColor: Color(0xFFF2F2F2),
                    iconBackground: Colors.white,
                  ),
                  const SizedBox(height: 14),
                  const RecovaFeatureCard(
                    title: 'Daily Activity Challenge',
                    subtitle:
                        'Dapatkan Tantangan harian untuk mengatasi rasa bosanmu',
                    assetPath: 'assets/images/home/icon_challenge.png',
                    backgroundColor: Color(0xFFF2F2F2),
                    iconBackground: Colors.white,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Bantu Pemulihan',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  _RecoveryActionCard(
                    title: 'Emergency Button',
                    subtitle:
                        'Dapatkan Bantuan instan ketika dalam waktu feeling tempted',
                    assetPath: 'assets/images/home/icon_emergency.png',
                    backgroundColor: const Color(0xFFFF9191),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmergencyPage(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  const _RecoveryActionCard(
                    title: 'Smart Personal AI Coach',
                    subtitle:
                        'Dapatkan Insight untuk Keluhan atau Pertanyaanmu',
                    assetPath: 'assets/images/home/icon_coach.png',
                    backgroundColor: Color(0xFFF0F0F0),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Today Insight',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  const _InsightPanel(),
                ],
              ),
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildWeekFooter(Statistics stats, int totalDays) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final trackedDays =
        stats.streakCalendar
            .map((date) => DateTime.parse(date))
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet();

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = DateTime(
                startOfWeek.year,
                startOfWeek.month,
                startOfWeek.day + index,
              );
              final checked = trackedDays.any(
                (item) =>
                    item.year == day.year &&
                    item.month == day.month &&
                    item.day == day.day,
              );
              final isToday =
                  day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      dayLabels[index],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5A6268),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color:
                            checked
                                ? const Color(0xFF2FB15A)
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              isToday
                                  ? const Color(0xFF2FB15A)
                                  : const Color(0xFFD5D5D5),
                          width: 1.6,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child:
                          checked
                              ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                              : null,
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Progress: ${stats.currentStreak} / $totalDays Days',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5E6B72),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: stats.currentStreak / totalDays,
              backgroundColor: const Color(0xFFD7D7D7),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2FB15A),
              ),
              minHeight: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCheckInTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '10 pm';
    }

    final normalized = value.trim().toLowerCase();
    if (normalized.contains(':')) {
      return normalized;
    }
    return normalized;
  }

  Future<void> _openCheckIn(
    Statistics stats,
    bool hasCheckedInToday,
    BuildContext context,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    _checkinCubit.resetState();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CheckInPage(
              streakDays: stats.currentStreak,
              hasCheckedInToday: hasCheckedInToday,
            ),
      ),
    );

    final resultState = _checkinCubit.state;
    if (resultState is CheckinSuccess) {
      _homeCubit.updateStreakAfterCheckin();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Check-in berhasil! ✅'),
            backgroundColor: Colors.green,
          ),
        );
    } else if (resultState is CheckinFailure) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Gagal check-in: ${resultState.error}'),
            backgroundColor: Colors.red,
          ),
        );
    }

    _checkinCubit.resetState();
    _homeCubit.fetchHomeData();
  }
}

class _RecoveryActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String assetPath;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _RecoveryActionCard({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Image.asset(assetPath, width: 24, height: 24),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '“Kamu sudah melakukan yang terbaik hari ini, hasil yang memuaskan datang dari hal kecil yang dilakukan secara konsisten.”',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Insight ini dibuat dari journal harian yang kamu tulis dan aktifitas daily check-in kamu',
            style: TextStyle(fontSize: 12, color: Color(0xFF97A0A7)),
          ),
        ],
      ),
    );
  }
}