import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/features/home/presentation/widgets/daily_motivation_card.dart';
import 'package:recova/features/home/presentation/widgets/home_header.dart';
import 'package:recova/features/home/presentation/widgets/quick_action_grid.dart';
import 'package:recova/features/home/presentation/widgets/streak_counter_card.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/services/api_service.dart';
import 'package:recova/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = context.read<HomeCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeCubit.fetchHomeData();
    });

    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await NotificationService.requestPermission();
    try {
      final user = await ApiService.getUserMe();
      await NotificationService.scheduleDailyNotification(
        checkinTime: user.dailyCheckinTime,
      );
    } catch (e) {
      debugPrint('[HomePage] Gagal fetch user untuk notifikasi: $e');
      await NotificationService.scheduleDailyNotification();
    }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
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
                    HomeHeader(nickname: user.nickname),
                    const SizedBox(height: 18),
                    StreakCounterCard(
                      currentStreak: stats.currentStreak,
                      progress: stats.streakGoalComparison?.progressRate ?? 0.0,
                      streakCalendar: stats.streakCalendar,
                      relapseCalendar: successState.relapseCalendar,
                      goalDays: user.pornFreeGoal ?? 0,
                    ),
                    const SizedBox(height: 24),
                    QuickActionGrid(
                      user: user,
                      stats: stats,
                      dailyContent: successState.dailyContent,
                      hasCheckedInToday: _hasCheckedInToday(stats),
                      onCheckInSuccess: () => _homeCubit.fetchHomeData(),
                    ),
                    const SizedBox(height: 26),
                    DailyMotivationCard(
                      dailyContent: successState.dailyContent,
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
