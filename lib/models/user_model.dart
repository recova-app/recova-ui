class User {
  final String id;
  final String email;
  final String nickname;
  final String? recoveryReason;
  final String? dailyCheckinTime;
  final int? pornFreeGoal;
  final bool onboardingCompleted;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    this.recoveryReason,
    this.dailyCheckinTime,
    this.pornFreeGoal,
    this.onboardingCompleted = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      recoveryReason: json['recovery_reason'],
      dailyCheckinTime: json['daily_checkin_time'],
      pornFreeGoal: json['porn_free_goal'] != null ? (json['porn_free_goal'] is int ? json['porn_free_goal'] : int.tryParse(json['porn_free_goal'].toString())) : null,
      onboardingCompleted: json['onboarding_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'recovery_reason': recoveryReason,
      'daily_checkin_time': dailyCheckinTime,
      'porn_free_goal': pornFreeGoal,
      'onboarding_completed': onboardingCompleted,
    };
  }
}
