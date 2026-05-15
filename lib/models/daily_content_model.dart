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

class PhysicalChallenge {
  final String title;
  final String description;

  const PhysicalChallenge({
    required this.title,
    required this.description,
  });

  factory PhysicalChallenge.fromJson(Map<String, dynamic> json) {
    return PhysicalChallenge(
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
  final PhysicalChallenge? physicalChallenge;

  const DailyContent({
    required this.date,
    required this.motivation,
    this.challenge,
    this.physicalChallenge,
  });

  factory DailyContent.fromJson(Map<String, dynamic> json) {
    DailyChallenge? challenge;
    if (json['challenge'] != null && json['challenge'] is Map<String, dynamic>) {
      challenge = DailyChallenge.fromJson(json['challenge']);
    }

    PhysicalChallenge? physicalChallenge;
    if (json['physical_challenge'] != null && json['physical_challenge'] is Map<String, dynamic>) {
      physicalChallenge = PhysicalChallenge.fromJson(json['physical_challenge']);
    }

    return DailyContent(
      date: json['date'] ?? '',
      motivation: json['motivation'] ?? '',
      challenge: challenge,
      physicalChallenge: physicalChallenge,
    );
  }
}

