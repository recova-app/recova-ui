import 'package:equatable/equatable.dart';

bool _parseBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return defaultValue;
}

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

/// DTO representing the response from `POST /api/v1/community/{post_id}/like` (`postCommunityLikeToggle`).
class CommunityLikeData extends Equatable {
  final int likedCount;
  final bool isLiked;

  const CommunityLikeData({required this.likedCount, required this.isLiked});

  factory CommunityLikeData.fromJson(Map<String, dynamic> json) {
    return CommunityLikeData(
      likedCount: _parseInt(json['liked_count'] ?? json['likedCount']),
      isLiked: _parseBool(json['is_liked'] ?? json['isLiked']),
    );
  }

  Map<String, dynamic> toJson() => {
    'liked_count': likedCount,
    'is_liked': isLiked,
  };

  CommunityLikeData copyWith({int? likedCount, bool? isLiked}) {
    return CommunityLikeData(
      likedCount: likedCount ?? this.likedCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [likedCount, isLiked];
}
