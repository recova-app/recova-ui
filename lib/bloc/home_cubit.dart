import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/models/daily_content_model.dart';
import 'package:recova/features/routine/domain/streak_calculator.dart';
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

      final longest =
          stats.longestStreak > computedCurrent
              ? stats.longestStreak
              : computedCurrent;

      final updatedStats = stats.copyWith(
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

      // Use relapse calendar from statistics model; fallback to separate query if empty
      List<String> relapseCalendar = stats.relapseCalendar;
      if (relapseCalendar.isEmpty) {
        try {
          final relapseStats = await ApiService.getRelapseStatistics();
          relapseCalendar = relapseStats.statistics.relapseCalendar;
        } catch (_) {
          // Silently ignore – weekly status will just not show relapse indicators
        }
      }

      emit(
        HomeLoadSuccess(
          user: user,
          statistics: updatedStats,
          dailyContent: dailyContent,
          relapseCalendar: relapseCalendar,
        ),
      );
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

      final nextStreak = currentStats.currentStreak + 1;
      final updatedStats = currentStats.copyWith(
        currentStreak: nextStreak,
        longestStreak:
            nextStreak > currentStats.longestStreak
                ? nextStreak
                : currentStats.longestStreak,
        totalCheckins: currentStats.totalCheckins + 1,
        streakCalendar: newCalendar,
      );

      emit(
        HomeLoadSuccess(
          user: currentState.user,
          statistics: updatedStats,
          dailyContent: currentState.dailyContent,
          relapseCalendar: currentState.relapseCalendar,
        ),
      );
    }
  }

  int _computeCurrentStreak(List<String> calendar) {
    return calculateStreakFromStrings(calendar);
  }
}
