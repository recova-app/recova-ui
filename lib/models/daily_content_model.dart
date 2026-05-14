class DailyContent {
  final String date;
  final String motivation;
  final String challenge;

  const DailyContent({
    required this.date,
    required this.motivation,
    required this.challenge,
  });

  factory DailyContent.fromJson(Map<String, dynamic> json) {
    return DailyContent(
      date: json['date'] ?? '',
      motivation: json['motivation'] ?? '',
      challenge: json['challenge'] ?? '',
    );
  }
}
