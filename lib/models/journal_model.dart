class Journal {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  Journal({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
