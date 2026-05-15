/// Full response model for /api/v1/routine/relapses/statistics
class RelapseStatisticsResponse {
  final RelapseStats statistics;
  final List<RelapseEntry> relapses;
  final List<HourlyRelapseDistribution> hourlyRelapseDistribution;
  final List<RelapseTriggerDistribution> relapseTriggerDistribution;
  final List<int> peakRelapseHoursUtc;
  final int peakRelapseCount;
  final String aiSummary;
  final RelapseTimeSummary? relapseTimeSummary;
  final RelapseTimeSummary? relapseTimeriggerSummary;
  final RelapseTimeSummary? latestRelapseSolution;

  RelapseStatisticsResponse({
    required this.statistics,
    required this.relapses,
    required this.hourlyRelapseDistribution,
    required this.relapseTriggerDistribution,
    required this.peakRelapseHoursUtc,
    required this.peakRelapseCount,
    required this.aiSummary,
    this.relapseTimeSummary,
    this.relapseTimeriggerSummary,
    this.latestRelapseSolution,
  });

  factory RelapseStatisticsResponse.fromJson(Map<String, dynamic> json) {
    return RelapseStatisticsResponse(
      statistics: RelapseStats.fromJson(json['statistics'] ?? {}),
      relapses: (json['relapses'] as List?)
              ?.map((e) => RelapseEntry.fromJson(e))
              .toList() ??
          [],
      hourlyRelapseDistribution:
          (json['hourly_relapse_distribution'] as List?)
                  ?.map((e) => HourlyRelapseDistribution.fromJson(e))
                  .toList() ??
              [],
      relapseTriggerDistribution:
          (json['relapse_triggers_distribution'] as List?)
                  ?.map((e) => RelapseTriggerDistribution.fromJson(e))
                  .toList() ??
              [],
      peakRelapseHoursUtc:
          List<int>.from(json['peak_relapse_hours_utc'] ?? []),
      peakRelapseCount: json['peak_relapse_count'] ?? 0,
      aiSummary: json['ai_summary'] ?? '',
      relapseTimeSummary: json['relapse_time_summary'] != null
          ? RelapseTimeSummary.fromJson(json['relapse_time_summary'])
          : null,
      relapseTimeriggerSummary: json['relapse_trigger_summary'] != null
          ? RelapseTimeSummary.fromJson(json['relapse_trigger_summary'])
          : null,
      latestRelapseSolution: json['latest_relapse_solution'] != null
          ? RelapseTimeSummary.fromJson(json['latest_relapse_solution'])
          : null,
    );
  }
}

class RelapseStats {
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
  final WeeklyMonthlyProgress? weeklyProgress;
  final WeeklyMonthlyProgress? monthlyProgress;
  final List<MoodTrendEntry> moodTrend;
  final String? lastCheckInDate;
  final String? lastCheckInDayName;
  final String? lastRelapseDate;
  final String? lastRelapseDayName;
  final List<WeekdaySummaryEntry> weekdaySummary;
  final StreakGoalComparisonData? streakGoalComparison;

  RelapseStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCheckins,
    required this.totalAttempts,
    required this.successRate,
    required this.streakCalendar,
    required this.relapseCalendar,
    required this.relapseCount,
    required this.relapseRate,
    required this.recoverySuccessRate,
    required this.checkinConsistencyScore,
    this.weeklyProgress,
    this.monthlyProgress,
    this.moodTrend = const [],
    this.lastCheckInDate,
    this.lastCheckInDayName,
    this.lastRelapseDate,
    this.lastRelapseDayName,
    this.weekdaySummary = const [],
    this.streakGoalComparison,
  });

  factory RelapseStats.fromJson(Map<String, dynamic> json) {
    return RelapseStats(
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
      weeklyProgress: json['weekly_progress'] != null
          ? WeeklyMonthlyProgress.fromJson(json['weekly_progress'])
          : null,
      monthlyProgress: json['monthly_progress'] != null
          ? WeeklyMonthlyProgress.fromJson(json['monthly_progress'])
          : null,
      moodTrend: (json['mood_trend'] as List?)
              ?.map((e) => MoodTrendEntry.fromJson(e))
              .toList() ??
          [],
      lastCheckInDate: json['last_check_in_date'],
      lastCheckInDayName: json['last_check_in_day_name'],
      lastRelapseDate: json['last_relapse_date'],
      lastRelapseDayName: json['last_relapse_day_name'],
      weekdaySummary: (json['weekday_summary'] as List?)
              ?.map((e) => WeekdaySummaryEntry.fromJson(e))
              .toList() ??
          [],
      streakGoalComparison: json['streak_goal_comparison'] != null
          ? StreakGoalComparisonData.fromJson(json['streak_goal_comparison'])
          : null,
    );
  }
}

class WeeklyMonthlyProgress {
  final int windowDays;
  final int currentSuccessfulCheckins;
  final int previousSuccessfulCheckins;
  final int delta;
  final double deltaRate;

  WeeklyMonthlyProgress({
    required this.windowDays,
    required this.currentSuccessfulCheckins,
    required this.previousSuccessfulCheckins,
    required this.delta,
    required this.deltaRate,
  });

  factory WeeklyMonthlyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyMonthlyProgress(
      windowDays: json['window_days'] ?? 7,
      currentSuccessfulCheckins: json['current_successful_checkins'] ?? 0,
      previousSuccessfulCheckins: json['previous_successful_checkins'] ?? 0,
      delta: json['delta'] ?? 0,
      deltaRate: (json['delta_rate'] ?? 0).toDouble(),
    );
  }
}

class MoodTrendEntry {
  final String date;
  final String dayName;
  final String dominantMood;
  final double successfulRatio;

  MoodTrendEntry({
    required this.date,
    required this.dayName,
    required this.dominantMood,
    required this.successfulRatio,
  });

  factory MoodTrendEntry.fromJson(Map<String, dynamic> json) {
    return MoodTrendEntry(
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
      dominantMood: json['dominant_mood'] ?? '',
      successfulRatio: (json['successful_ratio'] ?? 0).toDouble(),
    );
  }
}

class WeekdaySummaryEntry {
  final String dayName;
  final int successfulCheckins;
  final int relapseCount;
  final int totalCheckins;
  final double successRate;

  WeekdaySummaryEntry({
    required this.dayName,
    required this.successfulCheckins,
    required this.relapseCount,
    required this.totalCheckins,
    required this.successRate,
  });

  factory WeekdaySummaryEntry.fromJson(Map<String, dynamic> json) {
    return WeekdaySummaryEntry(
      dayName: json['day_name'] ?? '',
      successfulCheckins: json['successful_checkins'] ?? 0,
      relapseCount: json['relapse_count'] ?? 0,
      totalCheckins: json['total_checkins'] ?? 0,
      successRate: (json['success_rate'] ?? 0).toDouble(),
    );
  }
}

class StreakGoalComparisonData {
  final int pornFreeGoal;
  final int currentStreak;
  final int longestStreak;
  final bool goalReached;
  final int remainingDays;
  final double progressRate;

  StreakGoalComparisonData({
    required this.pornFreeGoal,
    required this.currentStreak,
    required this.longestStreak,
    required this.goalReached,
    required this.remainingDays,
    required this.progressRate,
  });

  factory StreakGoalComparisonData.fromJson(Map<String, dynamic> json) {
    return StreakGoalComparisonData(
      pornFreeGoal: json['porn_free_goal'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      goalReached: json['goal_reached'] ?? false,
      remainingDays: json['remaining_days'] ?? 0,
      progressRate: (json['progress_rate'] ?? 0).toDouble(),
    );
  }
}

class RelapseEntry {
  final String id;
  final String userId;
  final String relapseDate;
  final String relapseDayName;
  final String mood;
  final String commitment;
  final List<String> relapseTrigger;
  final String? checkInId;
  final String createdAt;

  RelapseEntry({
    required this.id,
    required this.userId,
    required this.relapseDate,
    required this.relapseDayName,
    required this.mood,
    required this.commitment,
    required this.relapseTrigger,
    this.checkInId,
    required this.createdAt,
  });

  factory RelapseEntry.fromJson(Map<String, dynamic> json) {
    return RelapseEntry(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      relapseDate: json['relapse_date'] ?? '',
      relapseDayName: json['relapse_day_name'] ?? '',
      mood: json['mood'] ?? '',
      commitment: json['commitment'] ?? '',
      relapseTrigger: List<String>.from(json['relapse_trigger'] ?? []),
      checkInId: json['check_in_id'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class HourlyRelapseDistribution {
  final int hourUtc;
  final int relapseCount;

  HourlyRelapseDistribution({
    required this.hourUtc,
    required this.relapseCount,
  });

  factory HourlyRelapseDistribution.fromJson(Map<String, dynamic> json) {
    return HourlyRelapseDistribution(
      hourUtc: json['hour_utc'] ?? 0,
      relapseCount: json['relapse_count'] ?? 0,
    );
  }
}

class RelapseTimeSummary {
  final String title;
  final String analysis;
  final String summary;
  final String? generatedAt;

  RelapseTimeSummary({
    required this.title,
    required this.analysis,
    required this.summary,
    this.generatedAt,
  });

  factory RelapseTimeSummary.fromJson(Map<String, dynamic> json) {
    return RelapseTimeSummary(
      title: json['title'] ?? '',
      analysis: json['analysis'] ?? '',
      summary: json['summary'] ?? '',
      generatedAt: json['generated_at'],
    );
  }
}

class RelapseTriggerDistribution {
  final String relapseTrigger;
  final int relapseTriggerCount;

  RelapseTriggerDistribution({
    required this.relapseTrigger,
    required this.relapseTriggerCount,
  });

  factory RelapseTriggerDistribution.fromJson(Map<String, dynamic> json) {
    return RelapseTriggerDistribution(
      relapseTrigger: json['relapse_trigger'] ?? '',
      relapseTriggerCount: json['relapse_trigger_count'] ?? 0,
    );
  }
}
