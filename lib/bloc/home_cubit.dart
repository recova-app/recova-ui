import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/models/daily_content_model.dart';
import 'package:recova/services/api_service.dart';
import 'package:equatable/equatable.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> fetchHomeData() async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        ApiService.getUserMe(),
        ApiService.getStatistics(),
      ]);

      final user = results[0] as User;
      final stats = results[1] as Statistics;
      final computedCurrent = _computeCurrentStreak(stats.streakCalendar);

      final longest = stats.longestStreak > computedCurrent
          ? stats.longestStreak
          : computedCurrent;

      final updatedStats = Statistics(
        currentStreak: computedCurrent,
        longestStreak: longest,
        totalCheckins: stats.streakCalendar.length,
        streakCalendar: List.from(stats.streakCalendar),
      );

      // Fetch daily content separately so failure doesn't block the page
      DailyContent? dailyContent;
      try {
        dailyContent = await ApiService.getDailyContent();
      } catch (_) {
        // Silently ignore – insight section will show fallback text
      }

      emit(HomeLoadSuccess(user: user, statistics: updatedStats, dailyContent: dailyContent));
    } catch (e) {
      emit(HomeLoadFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void updateStreakAfterCheckin() {
    if (state is HomeLoadSuccess) {
      final currentState = state as HomeLoadSuccess;
      final currentStats = currentState.statistics;

      // Tambahkan tanggal hari ini ke kalender
      final newCalendar = List<String>.from(currentStats.streakCalendar)
        ..add(DateTime.now().toIso8601String());

      final updatedStats = Statistics(
        currentStreak: currentStats.currentStreak + 1,
        longestStreak: (currentStats.currentStreak + 1) > currentStats.longestStreak
            ? currentStats.currentStreak + 1
            : currentStats.longestStreak,
        totalCheckins: currentStats.totalCheckins + 1,
        streakCalendar: newCalendar,
      );

      emit(HomeLoadSuccess(user: currentState.user, statistics: updatedStats, dailyContent: currentState.dailyContent));
    }
  }

  int _computeCurrentStreak(List<String> calendar) {
    if (calendar.isEmpty) return 0;

    final dates = calendar
        .map((s) => DateTime.parse(s))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet() // Use a Set to handle duplicates automatically
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Jika check-in terakhir bukan hari ini atau kemarin, streaknya pasti 0.
    if (dates.first.isBefore(yesterday)) {
      return 0;
    }

    // Mulai streak dari 1 jika check-in terakhir adalah hari ini, atau 0 jika kemarin (akan dihitung di loop).
    int streak = dates.first == today ? 1 : 0;
    // Jika check-in terakhir adalah kemarin, kita mulai dari tanggal itu.

    for (int i = 0; i < dates.length - 1; i++) {
      // Jika check-in terakhir hari ini, kita mulai dari elemen pertama.
      // Jika check-in terakhir kemarin, kita mulai dari elemen kedua.
      if (dates[i].difference(dates[i+1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}