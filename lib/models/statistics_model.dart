class Statistics {
  final int currentStreak;
  final int longestStreak;
  final int totalCheckins;
  final List<String> streakCalendar;
  final int relapseCount;
  final double relapseRate;
  final double recoverySuccessRate;
  final double checkinConsistencyScore;
  final WeeklyProgress? weeklyProgress;
  final MonthlyProgress? monthlyProgress;
  final List<MoodTrend> moodTrend;
  final StreakGoalComparison? streakGoalComparison;

  Statistics({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCheckins,
    required this.streakCalendar,
    this.relapseCount = 0,
    this.relapseRate = 0.0,
    this.recoverySuccessRate = 0.0,
    this.checkinConsistencyScore = 0.0,
    this.weeklyProgress,
    this.monthlyProgress,
    this.moodTrend = const [],
    this.streakGoalComparison,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      totalCheckins: json['total_checkins'] ?? 0,
      streakCalendar: List<String>.from(json['streak_calendar'] ?? []),
      relapseCount: json['relapse_count'] ?? 0,
      relapseRate: (json['relapse_rate'] ?? 0).toDouble(),
      recoverySuccessRate: (json['recovery_success_rate'] ?? 0).toDouble(),
      checkinConsistencyScore: (json['checkin_consistency_score'] ?? 0).toDouble(),
      weeklyProgress: json['weekly_progress'] != null
          ? WeeklyProgress.fromJson(json['weekly_progress'])
          : null,
      monthlyProgress: json['monthly_progress'] != null
          ? MonthlyProgress.fromJson(json['monthly_progress'])
          : null,
      moodTrend: (json['mood_trend'] as List?)
              ?.map((e) => MoodTrend.fromJson(e))
              .toList() ??
          [],
      streakGoalComparison: json['streak_goal_comparison'] != null
          ? StreakGoalComparison.fromJson(json['streak_goal_comparison'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_checkins': totalCheckins,
      'streak_calendar': streakCalendar,
      'relapse_count': relapseCount,
      'relapse_rate': relapseRate,
      'recovery_success_rate': recoverySuccessRate,
      'checkin_consistency_score': checkinConsistencyScore,
      'weekly_progress': weeklyProgress?.toJson(),
      'monthly_progress': monthlyProgress?.toJson(),
      'mood_trend': moodTrend.map((e) => e.toJson()).toList(),
      'streak_goal_comparison': streakGoalComparison?.toJson(),
    };
  }
}

class WeeklyProgress {
  final int windowDays;
  final int currentSuccessfulCheckins;
  final int previousSuccessfulCheckins;
  final int delta;
  final double deltaRate;

  WeeklyProgress({
    required this.windowDays,
    required this.currentSuccessfulCheckins,
    required this.previousSuccessfulCheckins,
    required this.delta,
    required this.deltaRate,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      windowDays: json['window_days'] ?? 7,
      currentSuccessfulCheckins: json['current_successful_checkins'] ?? 0,
      previousSuccessfulCheckins: json['previous_successful_checkins'] ?? 0,
      delta: json['delta'] ?? 0,
      deltaRate: (json['delta_rate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'window_days': windowDays,
      'current_successful_checkins': currentSuccessfulCheckins,
      'previous_successful_checkins': previousSuccessfulCheckins,
      'delta': delta,
      'delta_rate': deltaRate,
    };
  }
}

class MonthlyProgress {
  final int windowDays;
  final int currentSuccessfulCheckins;
  final int previousSuccessfulCheckins;
  final int delta;
  final double deltaRate;

  MonthlyProgress({
    required this.windowDays,
    required this.currentSuccessfulCheckins,
    required this.previousSuccessfulCheckins,
    required this.delta,
    required this.deltaRate,
  });

  factory MonthlyProgress.fromJson(Map<String, dynamic> json) {
    return MonthlyProgress(
      windowDays: json['window_days'] ?? 30,
      currentSuccessfulCheckins: json['current_successful_checkins'] ?? 0,
      previousSuccessfulCheckins: json['previous_successful_checkins'] ?? 0,
      delta: json['delta'] ?? 0,
      deltaRate: (json['delta_rate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'window_days': windowDays,
      'current_successful_checkins': currentSuccessfulCheckins,
      'previous_successful_checkins': previousSuccessfulCheckins,
      'delta': delta,
      'delta_rate': deltaRate,
    };
  }
}

class MoodTrend {
  final String date;
  final String dominantMood;
  final double successfulRatio;

  MoodTrend({
    required this.date,
    required this.dominantMood,
    required this.successfulRatio,
  });

  factory MoodTrend.fromJson(Map<String, dynamic> json) {
    return MoodTrend(
      date: json['date'] ?? '',
      dominantMood: json['dominant_mood'] ?? '',
      successfulRatio: (json['successful_ratio'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dominant_mood': dominantMood,
      'successful_ratio': successfulRatio,
    };
  }
}

class StreakGoalComparison {
  final int pornFreeGoal;
  final int currentStreak;
  final int longestStreak;
  final bool goalReached;
  final int remainingDays;
  final double progressRate;

  StreakGoalComparison({
    required this.pornFreeGoal,
    required this.currentStreak,
    required this.longestStreak,
    required this.goalReached,
    required this.remainingDays,
    required this.progressRate,
  });

  factory StreakGoalComparison.fromJson(Map<String, dynamic> json) {
    return StreakGoalComparison(
      pornFreeGoal: json['porn_free_goal'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      goalReached: json['goal_reached'] ?? false,
      remainingDays: json['remaining_days'] ?? 0,
      progressRate: (json['progress_rate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'porn_free_goal': pornFreeGoal,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'goal_reached': goalReached,
      'remaining_days': remainingDays,
      'progress_rate': progressRate,
    };
  }
}
