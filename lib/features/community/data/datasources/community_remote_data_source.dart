import 'package:recova/core/network/api_client.dart';
import 'package:recova/models/community_like_data.dart';
import 'package:recova/models/post_model.dart';

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

/// Remote data source contract for peer community operations.
abstract class CommunityRemoteDataSource {
  /// Fetch community posts with optional category filter (GET /api/v1/community)
  Future<List<Post>> getPosts({String? category});

  /// Create new community post (POST /api/v1/community)
  Future<Post> createPost({
    required String title,
    required String content,
    required String category,
  });

  /// Toggle like status on post (POST /api/v1/community/{post_id}/like)
  Future<CommunityLikeData> toggleLike(String postId);
}

/// Implementation of [CommunityRemoteDataSource] backed by injectable [ApiClient].
class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  CommunityRemoteDataSourceImpl({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static String normalizeCategory(String category) {
    final normalized = category.toLowerCase().trim();
    switch (normalized) {
      case 'nasihat':
      case 'advice':
      case 'saran':
        return 'saran';
      case 'bantuan':
      case 'help':
        return 'bantuan';
      case 'motivasi':
      case 'motivation':
        return 'motivasi';
      case 'cerita':
      case 'story':
        return 'cerita';
      case 'pertanyaan':
      case 'question':
        return 'pertanyaan';
      default:
        return normalized;
    }
  }

  @override
  Future<List<Post>> getPosts({String? category}) async {
    final Map<String, dynamic>? queryParams;
    if (category != null &&
        category.trim().isNotEmpty &&
        category.trim().toLowerCase() != 'semua' &&
        category.trim().toLowerCase() != 'all') {
      queryParams = {'category': normalizeCategory(category)};
    } else {
      queryParams = null;
    }

    final response = await _apiClient.get<List<Post>>(
      '/community',
      queryParameters: queryParams,
      fromJson: (rawData) {
        if (rawData is List) {
          return rawData
              .whereType<Map>()
              .map((item) => Post.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
        return <Post>[];
      },
    );

    return response.data;
  }

  @override
  Future<Post> createPost({
    required String title,
    required String content,
    required String category,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'content': content,
      'category': normalizeCategory(category),
    };

    final response = await _apiClient.post<Post>(
      '/community',
      data: payload,
      fromJson: (rawData) => Post.fromJson(_asMap(rawData)),
    );

    return response.data;
  }

  @override
  Future<CommunityLikeData> toggleLike(String postId) async {
    final response = await _apiClient.post<CommunityLikeData>(
      '/community/$postId/like',
      fromJson: (rawData) => CommunityLikeData.fromJson(_asMap(rawData)),
    );

    return response.data;
  }
}
