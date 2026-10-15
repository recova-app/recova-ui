import 'package:recova/models/community_like_data.dart';
import 'package:recova/models/post_model.dart';

/// Abstract repository defining domain operations for peer community posts
/// and atomic like status toggling.
abstract class CommunityRepository {
  /// Fetch list of community posts with optional category filter
  Future<List<Post>> getPosts({String? category});

  /// Create a new community post
  Future<Post> createPost({
    required String title,
    required String content,
    required String category,
  });

  /// Toggle like status for a community post atomically (POST /api/v1/community/{post_id}/like)
  Future<CommunityLikeData> toggleLike(String postId);
}
