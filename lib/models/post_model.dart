import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String title;
  final String content;
  final String category;
  final int commentCount;
  final int likeCount;
  final DateTime createdAt;
  final String userId;
  final String? username; // Opsional, jika backend mengirimkannya
  final int? userStreak; // Opsional, jika backend mengirimkannya
  final bool isLiked; // Untuk melacak apakah post ini sudah di-like oleh user

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.commentCount,
    required this.likeCount,
    required this.createdAt,
    required this.userId,
    this.username,
    this.userStreak,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? json['user'] ?? {};
    final categoryValue = (json['category'] ?? 'Nasihat').toString();

    return Post(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      // Asumsi backend mengirim 'category'
      category: categoryValue.isEmpty ? 'Nasihat' : categoryValue,
      commentCount: _readInt(json['commentCount'] ?? json['comment_count']),
      likeCount: _readInt(json['likeCount'] ?? json['like_count']),
      createdAt: _parseServerDateTime(json['createdAt'] ?? json['created_at']),
      userId:
          (json['userId'] ?? json['user_id'] ?? author['id'] ?? '').toString(),
      // Jika backend mengirim data user, kita bisa parse di sini
      username:
          (author['nickname'] ?? author['username'] ?? 'Anonim').toString(),
      userStreak: _readInt(author['currentStreak'] ?? author['current_streak']),
      // Asumsi backend mengirim field 'isLiked'
      isLiked: _parseBool(json['isLiked'] ?? json['is_liked']),
    );
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    int? commentCount,
    int? likeCount,
    DateTime? createdAt,
    String? userId,
    String? username,
    int? userStreak,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userStreak: userStreak ?? this.userStreak,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // Helper untuk mengubah Post menjadi Map yang bisa dipakai di PostCard
  Map<String, dynamic> toPostCardMap() {
    return {
      'id': id,
      'username': username,
      'likes': likeCount,
      'text': content,
      'streak': userStreak,
      'category': category,
      'isLiked': isLiked,
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return defaultValue;
  }

  static DateTime _parseServerDateTime(dynamic value) {
    final raw = (value ?? '').toString();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return DateTime.now();
    return parsed.toLocal();
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    category,
    commentCount,
    likeCount,
    createdAt,
    userId,
    username,
    userStreak,
    isLiked,
  ];
}

typedef CommunityPostData = Post;
