import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/features/home/presentation/cubit/home_cubit.dart';
import 'package:recova/features/home/presentation/widgets/daily_motivation_card.dart';
import 'package:recova/features/home/presentation/widgets/home_header.dart';
import 'package:recova/features/home/presentation/widgets/quick_action_grid.dart';
import 'package:recova/features/home/presentation/widgets/streak_counter_card.dart';
import 'package:recova/models/statistics_model.dart';
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
    try {
      await NotificationService.requestPermission();
    } catch (e) {
      debugPrint('[HomePage] Gagal request permission notifikasi: $e');
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
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          if (state is HomeLoadSuccess) {
            NotificationService.scheduleDailyNotification(
              checkinTime: state.user.dailyCheckinTime,
            );
          }
        },
        builder: (context, state) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

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
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _homeCubit.fetchHomeData(),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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
              color: colorScheme.primary,
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
