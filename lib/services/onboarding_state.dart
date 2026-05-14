class OnboardingState {
  static final OnboardingState _instance = OnboardingState._internal();
  factory OnboardingState() => _instance;
  OnboardingState._internal();

  String nickname = '';
  String recoveryReason = '';
  String dailyCheckinTime = '09:00';
  String pornFreeGoal = '';
  Map<String, dynamic> answers = {};

  void reset() {
    nickname = '';
    recoveryReason = '';
    dailyCheckinTime = '09:00';
    pornFreeGoal = '';
    answers = {};
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'recovery_reason': recoveryReason,
      'daily_checkin_time': dailyCheckinTime,
      'porn_free_goal': pornFreeGoal,
      'answers': answers,
    };
  }
}
