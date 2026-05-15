class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.depth,
    required this.replyCount,
    required this.authorName,
    required this.replies,
  });

  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final int depth;
  final int replyCount;
  final String authorName;
  final List<CommunityComment> replies;

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    final repliesJson = json['replies'];
    final author = json['author'] ?? json['user'] ?? {};

    return CommunityComment(
      id: (json['id'] ?? '').toString(),
      postId: (json['post_id'] ?? json['postId'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: _parseServerDateTime(json['created_at'] ?? json['createdAt']),
      depth: _toInt(json['depth']),
      replyCount: _toInt(json['reply_count'] ?? json['replyCount']),
      authorName: (author['nickname'] ?? author['username'] ?? 'Anonim').toString(),
      replies: repliesJson is List
          ? repliesJson
              .whereType<Map>()
              .map((e) => CommunityComment.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseServerDateTime(dynamic value) {
    final raw = (value ?? '').toString();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return DateTime.now();
    return parsed.toLocal();
  }
}
