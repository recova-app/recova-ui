class Statistics {
  final int currentStreak;
  final int longestStreak;
  final int totalCheckins;
  final int totalAttempts;
  final double successRate;
  final List<String> streakCalendar;
  final List<String> relapseCalendar;
  final int relapseCount;
  final double relapseRate;
  final double recoverySuccessRate;
  final double checkinConsistencyScore;
  final WeeklyProgress? weeklyProgress;
  final MonthlyProgress? monthlyProgress;
  final List<MoodTrend> moodTrend;
  final StreakGoalComparison? streakGoalComparison;
  final String? lastCheckInDate;
  final String? lastCheckInDayName;
  final String? lastRelapseDate;
  final String? lastRelapseDayName;

  Statistics({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCheckins,
    required this.streakCalendar,
    this.totalAttempts = 0,
    this.successRate = 0.0,
    this.relapseCalendar = const [],
    this.relapseCount = 0,
    this.relapseRate = 0.0,
    this.recoverySuccessRate = 0.0,
    this.checkinConsistencyScore = 0.0,
    this.weeklyProgress,
    this.monthlyProgress,
    this.moodTrend = const [],
    this.streakGoalComparison,
    this.lastCheckInDate,
    this.lastCheckInDayName,
    this.lastRelapseDate,
    this.lastRelapseDayName,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      totalCheckins: json['total_checkins'] ?? 0,
      totalAttempts: json['total_attempts'] ?? 0,
      successRate: (json['success_rate'] ?? 0).toDouble(),
      streakCalendar: List<String>.from(json['streak_calendar'] ?? []),
      relapseCalendar: List<String>.from(json['relapse_calendar'] ?? []),
      relapseCount: json['relapse_count'] ?? 0,
      relapseRate: (json['relapse_rate'] ?? 0).toDouble(),
      recoverySuccessRate: (json['recovery_success_rate'] ?? 0).toDouble(),
      checkinConsistencyScore:
          (json['checkin_consistency_score'] ?? 0).toDouble(),
      weeklyProgress:
          json['weekly_progress'] != null
              ? WeeklyProgress.fromJson(json['weekly_progress'])
              : null,
      monthlyProgress:
          json['monthly_progress'] != null
              ? MonthlyProgress.fromJson(json['monthly_progress'])
              : null,
      moodTrend:
          (json['mood_trend'] as List?)
              ?.map((e) => MoodTrend.fromJson(e))
              .toList() ??
          [],
      streakGoalComparison:
          json['streak_goal_comparison'] != null
              ? StreakGoalComparison.fromJson(json['streak_goal_comparison'])
              : null,
      lastCheckInDate: json['last_check_in_date'],
      lastCheckInDayName: json['last_check_in_day_name'],
      lastRelapseDate: json['last_relapse_date'],
      lastRelapseDayName: json['last_relapse_day_name'],
    );
  }

  Statistics copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalCheckins,
    int? totalAttempts,
    double? successRate,
    List<String>? streakCalendar,
    List<String>? relapseCalendar,
    int? relapseCount,
    double? relapseRate,
    double? recoverySuccessRate,
    double? checkinConsistencyScore,
    WeeklyProgress? weeklyProgress,
    MonthlyProgress? monthlyProgress,
    List<MoodTrend>? moodTrend,
    StreakGoalComparison? streakGoalComparison,
    String? lastCheckInDate,
    String? lastCheckInDayName,
    String? lastRelapseDate,
    String? lastRelapseDayName,
  }) {
    return Statistics(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCheckins: totalCheckins ?? this.totalCheckins,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      successRate: successRate ?? this.successRate,
      streakCalendar: streakCalendar ?? this.streakCalendar,
      relapseCalendar: relapseCalendar ?? this.relapseCalendar,
      relapseCount: relapseCount ?? this.relapseCount,
      relapseRate: relapseRate ?? this.relapseRate,
      recoverySuccessRate: recoverySuccessRate ?? this.recoverySuccessRate,
      checkinConsistencyScore:
          checkinConsistencyScore ?? this.checkinConsistencyScore,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      monthlyProgress: monthlyProgress ?? this.monthlyProgress,
      moodTrend: moodTrend ?? this.moodTrend,
      streakGoalComparison: streakGoalComparison ?? this.streakGoalComparison,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      lastCheckInDayName: lastCheckInDayName ?? this.lastCheckInDayName,
      lastRelapseDate: lastRelapseDate ?? this.lastRelapseDate,
      lastRelapseDayName: lastRelapseDayName ?? this.lastRelapseDayName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_checkins': totalCheckins,
      'total_attempts': totalAttempts,
      'success_rate': successRate,
      'streak_calendar': streakCalendar,
      'relapse_calendar': relapseCalendar,
      'relapse_count': relapseCount,
      'relapse_rate': relapseRate,
      'recovery_success_rate': recoverySuccessRate,
      'checkin_consistency_score': checkinConsistencyScore,
      'weekly_progress': weeklyProgress?.toJson(),
      'monthly_progress': monthlyProgress?.toJson(),
      'mood_trend': moodTrend.map((e) => e.toJson()).toList(),
      'streak_goal_comparison': streakGoalComparison?.toJson(),
      'last_check_in_date': lastCheckInDate,
      'last_check_in_day_name': lastCheckInDayName,
      'last_relapse_date': lastRelapseDate,
      'last_relapse_day_name': lastRelapseDayName,
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
