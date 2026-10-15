import 'package:recova/features/community/data/datasources/community_remote_data_source.dart';
import 'package:recova/features/community/domain/repositories/community_repository.dart';
import 'package:recova/models/community_comment_model.dart';
import 'package:recova/models/community_like_data.dart';
import 'package:recova/models/post_model.dart';

/// Implementation of [CommunityRepository] orchestrating [CommunityRemoteDataSource].
class CommunityRepositoryImpl implements CommunityRepository {
  CommunityRepositoryImpl({CommunityRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? CommunityRemoteDataSourceImpl();

  final CommunityRemoteDataSource _remoteDataSource;

  @override
  Future<List<Post>> getPosts({String? category}) {
    return _remoteDataSource.getPosts(category: category);
  }

  @override
  Future<Post> createPost({
    required String title,
    required String content,
    required String category,
  }) {
    return _remoteDataSource.createPost(
      title: title,
      content: content,
      category: category,
    );
  }

  @override
  Future<CommunityLikeData> toggleLike(String postId) {
    return _remoteDataSource.toggleLike(postId);
  }

  @override
  Future<List<CommunityComment>> getPostComments(String postId) {
    return _remoteDataSource.getPostComments(postId);
  }

  @override
  Future<void> addPostComment({
    required String postId,
    required String content,
  }) {
    return _remoteDataSource.addPostComment(postId: postId, content: content);
  }

  @override
  Future<void> addCommentReply({
    required String postId,
    required String commentId,
    required String content,
  }) {
    return _remoteDataSource.addCommentReply(
      postId: postId,
      commentId: commentId,
      content: content,
    );
  }
}
