import 'package:get/get.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/services/api_service.dart';

import 'package:recova/states/home/home_state.dart';

export 'package:recova/states/home/home_state.dart';

class HomeController extends GetxController {
  late final Rx<HomeState> state;

  @override
  void onInit() {
    super.onInit();
    if (ApiService.useMockData) {
      state = Rx<HomeState>(
        HomeLoadSuccess(
          user: ApiService.mockUser,
          statistics: ApiService.mockStatistics,
        ),
      );
    } else {
      state = Rx<HomeState>(HomeInitial());
    }
  }

  Future<void> fetchHomeData() async {
    if (ApiService.useMockData) {
      state.value = HomeLoadSuccess(
        user: ApiService.mockUser,
        statistics: ApiService.mockStatistics,
      );
      return;
    }

    state.value = HomeLoading();
    try {
      final results = await Future.wait([
        ApiService.getUserMe(),
        ApiService.getStatistics(),
      ]);

      final user = results[0] as User;
      final stats = results[1] as Statistics;
      final computedCurrent = _computeCurrentStreak(stats.streakCalendar);

      final longest =
          stats.longestStreak > computedCurrent
              ? stats.longestStreak
              : computedCurrent;

      final updatedStats = Statistics(
        currentStreak: computedCurrent,
        longestStreak: longest,
        totalCheckins: stats.streakCalendar.length,
        streakCalendar: List.from(stats.streakCalendar),
      );

      state.value = HomeLoadSuccess(user: user, statistics: updatedStats);
    } catch (e) {
      state.value = HomeLoadFailure(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void updateStreakAfterCheckin() {
    final currentState = state.value;
    if (currentState is HomeLoadSuccess) {
      final currentStats = currentState.statistics;

      final newCalendar = List<String>.from(currentStats.streakCalendar)
        ..add(DateTime.now().toIso8601String());

      final updatedStats = Statistics(
        currentStreak: currentStats.currentStreak + 1,
        longestStreak:
            (currentStats.currentStreak + 1) > currentStats.longestStreak
                ? currentStats.currentStreak + 1
                : currentStats.longestStreak,
        totalCheckins: currentStats.totalCheckins + 1,
        streakCalendar: newCalendar,
      );

      state.value = HomeLoadSuccess(
        user: currentState.user,
        statistics: updatedStats,
      );
    }
  }

  int _computeCurrentStreak(List<String> calendar) {
    if (calendar.isEmpty) return 0;

    final dates =
        calendar
            .map((s) => DateTime.parse(s))
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dates.first.isBefore(yesterday)) {
      return 0;
    }

    int streak = dates.first == today ? 1 : 0;

    for (int i = 0; i < dates.length - 1; i++) {
      if (dates[i].difference(dates[i + 1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
