class DailyChallenge {
  final String title;
  final String description;

  const DailyChallenge({
    required this.title,
    required this.description,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  bool get isEmpty => title.isEmpty && description.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class DailyContent {
  final String date;
  final String motivation;
  final DailyChallenge? challenge;

  const DailyContent({
    required this.date,
    required this.motivation,
    this.challenge,
  });

  factory DailyContent.fromJson(Map<String, dynamic> json) {
    DailyChallenge? challenge;
    if (json['challenge'] != null && json['challenge'] is Map<String, dynamic>) {
      challenge = DailyChallenge.fromJson(json['challenge']);
    }

    return DailyContent(
      date: json['date'] ?? '',
      motivation: json['motivation'] ?? '',
      challenge: challenge,
    );
  }
}
