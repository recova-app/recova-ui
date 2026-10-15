import 'package:recova/features/community/data/datasources/community_remote_data_source.dart';
import 'package:recova/features/community/domain/repositories/community_repository.dart';
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
}
