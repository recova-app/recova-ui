import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/checkin_cubit.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/bloc/relapse_cubit.dart';
import 'package:recova/models/daily_content_model.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/pages/checkin_page.dart';
import 'package:recova/pages/emergency_page.dart';
import 'package:recova/pages/login_page.dart';
import 'package:recova/pages/relapse_page.dart';
import 'package:recova/services/api_service.dart';
import 'package:recova/services/auth_service.dart';

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
      MaterialPageRoute(builder: (_) => const LoginPage()),
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

  void _showDailyChallengePopup(BuildContext context, DailyChallenge? challenge) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _DailyChallengeDialog(challenge: challenge),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
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
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _homeCubit.fetchHomeData(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final successState = state as HomeLoadSuccess;
          final user = successState.user;
          final stats = successState.statistics;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _homeCubit.fetchHomeData(),
              color: const Color(0xFF38B768),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
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
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 64,
                            height: 64,
                          ),
                        ),
                        const Icon(Icons.notifications_none_rounded, color: Color(0xFF6B7280),),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Halo, ${user.nickname}!',
                      style: const TextStyle(
                        fontSize: 38 * 0.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Proud of you for showing up today',
                      style: TextStyle(fontSize: 34 * 0.42, color: Color(0xFF8B98A0)),
                    ),
                    const SizedBox(height: 18),
                    _StreakCard(
                      currentStreak: stats.currentStreak,
                      progress: stats.streakGoalComparison?.progressRate ?? 0.0,
                      streakCalendar: stats.streakCalendar,
                      goalDays: user.pornFreeGoal ?? 0,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Daily Routine',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final checkinCubit = context.read<CheckinCubit>();
                        checkinCubit.resetState();
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => BlocProvider.value(
                                  value: checkinCubit,
                                  child: CheckInPage(
                                    streakDays: stats.currentStreak,
                                    hasCheckedInToday: _hasCheckedInToday(stats),
                                  ),
                                ),
                          ),
                        );
                        // Refresh home data when returning from a successful check-in
                        if (result == true) {
                          _homeCubit.fetchHomeData();
                        }
                      },
                      child: _FeatureCard(
                        title: 'Check-In Harian Diatur Saat ${user.dailyCheckinTime ?? "6pm"}',
                        subtitle: 'Klik untuk Check-In lebih awal',
                        assetPath: 'assets/images/maskots/set-checkin-time.png',
                        bg: const Color(0xFFEAF9F1),
                        arrow: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final relapseCubit = context.read<RelapseCubit>();
                        relapseCubit.resetState();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: relapseCubit,
                              child: RelapsePage(
                                streakDays: stats.currentStreak,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const _FeatureCard(
                        title: 'Relapse',
                        subtitle: 'Akui, evaluasi, dan reset progress kamu.',
                        assetPath: 'assets/images/maskots/learning-5.png',
                        bg: Color(0xFFEAF9F1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _showDailyChallengePopup(
                          context,
                          successState.dailyContent?.challenge,
                        );
                      },
                      child: const _FeatureCard(
                        title: 'Daily Activity Challenge',
                        subtitle:
                            'Dapatkan Tantangan harian untuk mengatasi rasa bosanmu',
                        assetPath: 'assets/images/maskots/activity.png',
                        bg: Color(0xFFEAF9F1),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Bantu Pemulihan',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    _FeatureCard(
                      title: 'Emergency Button',
                      subtitle:
                          'Dapatkan Bantuan instan ketika dalam waktu feeling tempted',
                      assetPath: 'assets/images/maskots/emergency.png',
                      bg: const Color(0xFFEAF9F1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmergencyPage(),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const _FeatureCard(
                      title: 'Smart Personal AI Coach',
                      subtitle: 'Dapatkan Insight untuk Keluhan atau Pertanyaanmu',
                      assetPath: 'assets/images/maskots/coach.png',
                      bg: Color(0xFFEAF9F1),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Today Insight',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF9F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            successState.dailyContent?.motivation ??
                                'Kamu sudah melakukan yang terbaik hari ini, hasil yang memuaskan datang dari hal kecil yang dilakukan secara konsisten.',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          if (successState.dailyContent?.challenge != null &&
                              successState.dailyContent!.challenge!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('🎯 ', style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          successState.dailyContent!.challenge!.title.isNotEmpty
                                              ? successState.dailyContent!.challenge!.title
                                              : 'Tantangan Hari Ini',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF136E4D),
                                          ),
                                        ),
                                        if (successState.dailyContent!.challenge!.description.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            successState.dailyContent!.challenge!.description,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1F6E4D),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Text(
                            'Insight ini disesuaikan dari journal harian yang kamu tulis dan aktivitas daily check-in kamu',
                            style: TextStyle(fontSize: 10, color: Color(0xFF7A7A7A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
      child: Stack(
        clipBehavior:
            Clip.antiAlias, // Memastikan gambar terpotong sesuai border radius kontainer
        children: [
          // Layer 1: Background dan Konten Utama
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Memberi ruang kosong di kiri jika diperlukan, atau langsung Expanded
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:
                        MainAxisSize
                            .min, // Agar kontainer tidak memaksa tinggi maksimal
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 31 * 0.42,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 18 * 0.42,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Jika ada arrow, tampilkan di depan gambar atau di sampingnya
                if (arrow) Icon(Icons.chevron_right, color: titleColor),
              ],
            ),
          ),

          // Layer 2: Gambar yang diposisikan (Positioned)
          Positioned(
            right:
                -10, // Sesuaikan angka ini untuk mengatur seberapa jauh gambar keluar ke kanan
            bottom:
                -15, // Sesuaikan angka ini untuk mengatur seberapa jauh gambar keluar ke bawah
            child: ClipRRect(
              // Opsional: Jika ingin gambar ikut terpotong lengkungan pojok kontainer
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(12),
              ),
              child: Image.asset(
                assetPath,
                width: 80, // Sesuaikan ukuran agar terlihat proporsional
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.currentStreak,
    required this.progress,
    required this.streakCalendar,
    required this.goalDays,
  });
  final int currentStreak;
  final double progress;
  final List<String> streakCalendar;
  final int goalDays;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFF136E4D,
        ), // Background utama diubah menjadi hijau agar lengkungan putih terlihat
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none, // Mengizinkan elemen meluap dari batas
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 140, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Streak Kamu',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currentStreak Hari',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Setelah Melakukan Daily Check-in streak kamu akan terupdate di tengah malam',
                      style: TextStyle(
                        color: Color(0xFFD1FAE5),
                        fontSize: 8,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: -30,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                  ),
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
              borderRadius: BorderRadius.circular(
                18,
              ), // Melengkungkan container putih seperti gambar
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    // Compute the Monday-Sunday range for the current week
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    // DateTime.monday == 1, so (weekday - 1) gives offset from Monday
                    final monday = today.subtract(Duration(days: now.weekday - 1));

                    // Parse streak calendar dates into a Set for O(1) lookup
                    final checkedDates = streakCalendar
                        .map((s) {
                          final d = DateTime.parse(s);
                          return DateTime(d.year, d.month, d.day);
                        })
                        .toSet();

                    final dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final dayDate = monday.add(Duration(days: index));
                        final isToday = dayDate == today;
                        final isCheckedIn = checkedDates.contains(dayDate);

                        return Column(
                          children: [
                            Text(
                              dayLabels[index],
                              style: TextStyle(
                                fontWeight:
                                    isToday ? FontWeight.w800 : FontWeight.w600,
                                color:
                                    isToday
                                        ? const Color(0xFF111111)
                                        : const Color(0xFF8B98A0),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (isCheckedIn)
                              // Checked-in day: solid green circle with white check
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF38B768),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            else if (isToday)
                              // Today but not checked in: outlined circle
                              Container(
                                width: 28,
                                height: 28,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF38B768),
                                    width: 1.5,
                                  ),
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD1E8CD),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Color(0xFF9ECEAA),
                                    size: 16,
                                  ),
                                ),
                              )
                            else
                              // Not checked in, not today: grey empty circle
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE5E7EB),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Progress: $currentStreak / $goalDays Days',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 14,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF38B768),
                    ),
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

class _DailyChallengeDialog extends StatefulWidget {
  final DailyChallenge? challenge;

  const _DailyChallengeDialog({this.challenge});

  @override
  State<_DailyChallengeDialog> createState() => _DailyChallengeDialogState();
}

class _DailyChallengeDialogState extends State<_DailyChallengeDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  DailyChallenge? _challenge;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _challenge = widget.challenge;
    if (_challenge == null || _challenge!.isEmpty) {
      _fetchChallenge();
    }

    _animController.forward();
  }

  Future<void> _fetchChallenge() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final content = await ApiService.getDailyContent();
      if (mounted) {
        setState(() {
          _challenge = content.challenge;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat tantangan. Coba lagi.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF136E4D).withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header with gradient background and mascot ──
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF136E4D), Color(0xFF22A06B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 100, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Activity\nChallenge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Selesaikan tantangan hari ini!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Mascot positioned on the right
                      Positioned(
                        right: -5,
                        bottom: -20,
                        child: Image.asset(
                          'assets/images/maskots/activity.png',
                          width: 110,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Body content ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
                  child: _buildBody(),
                ),
                // ── Close button ──
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFF136E4D),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Memuat tantangan...',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 36, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _fetchChallenge,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF136E4D),
              ),
            ),
          ],
        ),
      );
    }

    if (_challenge == null || _challenge!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF9F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFF38B768),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada tantangan hari ini',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cek lagi nanti ya!',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Challenge title card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF9F1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD1FAE5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38B768),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _challenge!.title.isNotEmpty
                          ? _challenge!.title
                          : 'Tantangan Hari Ini',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
              if (_challenge!.description.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _challenge!.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Motivational hint
        Row(
          children: [
            const Text('💡 ', style: TextStyle(fontSize: 14)),
            Expanded(
              child: Text(
                'Tantangan ini dirancang untuk membantumu tetap produktif dan fokus.',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF6B7280).withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
