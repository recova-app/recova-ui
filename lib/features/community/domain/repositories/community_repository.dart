import 'package:recova/models/community_comment_model.dart';
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

  /// Fetch comment thread for a community post (GET /api/v1/community/{post_id}/comments)
  Future<List<CommunityComment>> getPostComments(String postId);

  /// Add comment to a community post (POST /api/v1/community/{post_id}/comments)
  Future<void> addPostComment({
    required String postId,
    required String content,
  });

  /// Add reply to a comment on a post (POST /api/v1/community/{post_id}/comments/{comment_id}/replies)
  Future<void> addCommentReply({
    required String postId,
    required String commentId,
    required String content,
  });
}
