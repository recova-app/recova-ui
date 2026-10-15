import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/checkin_cubit.dart';
import 'package:recova/bloc/relapse_cubit.dart';
import 'package:recova/features/home/presentation/widgets/daily_challenge_dialog.dart';
import 'package:recova/features/home/presentation/widgets/home_feature_card.dart';
import 'package:recova/models/daily_content_model.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/pages/checkin_page.dart';
import 'package:recova/pages/coach_page.dart';
import 'package:recova/pages/emergency_page.dart';
import 'package:recova/pages/relapse_page.dart';

class QuickActionGrid extends StatelessWidget {
  final User user;
  final Statistics stats;
  final DailyContent? dailyContent;
  final bool hasCheckedInToday;
  final VoidCallback? onCheckInSuccess;

  const QuickActionGrid({
    super.key,
    required this.user,
    required this.stats,
    this.dailyContent,
    this.hasCheckedInToday = false,
    this.onCheckInSuccess,
  });

  void _showDailyChallengePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder:
          (ctx) => DailyChallengeDialog(challenge: dailyContent?.challenge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Routine',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        HomeFeatureCard(
          title:
              'Check-In Harian Diatur Saat ${user.dailyCheckinTime ?? "6pm"}',
          subtitle: 'Klik untuk Check-In lebih awal',
          assetPath: 'assets/images/maskots/set-checkin-time.png',
          bg: const Color(0xFFEAF9F1),
          arrow: true,
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
                        hasCheckedInToday: hasCheckedInToday,
                      ),
                    ),
              ),
            );
            if (result == true) {
              onCheckInSuccess?.call();
            }
          },
        ),
        const SizedBox(height: 12),
        HomeFeatureCard(
          title: 'Relapse',
          subtitle: 'Akui, evaluasi, dan reset progress kamu.',
          assetPath: 'assets/images/maskots/learning-5.png',
          bg: const Color(0xFFEAF9F1),
          onTap: () {
            final relapseCubit = context.read<RelapseCubit>();
            relapseCubit.resetState();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BlocProvider.value(
                      value: relapseCubit,
                      child: RelapsePage(streakDays: stats.currentStreak),
                    ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        HomeFeatureCard(
          title: 'Daily Activity Challenge',
          subtitle: 'Dapatkan Tantangan harian untuk mengatasi rasa bosanmu',
          assetPath: 'assets/images/maskots/activity.png',
          bg: const Color(0xFFEAF9F1),
          onTap: () => _showDailyChallengePopup(context),
        ),
        const SizedBox(height: 26),
        Text(
          'Bantu Pemulihan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        HomeFeatureCard(
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
        HomeFeatureCard(
          title: 'Smart Personal AI Coach',
          subtitle: 'Dapatkan Insight untuk Keluhan atau Pertanyaanmu',
          assetPath: 'assets/images/maskots/coach.png',
          bg: const Color(0xFFEAF9F1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CoachPage()),
            );
          },
        ),
      ],
    );
  }
}
