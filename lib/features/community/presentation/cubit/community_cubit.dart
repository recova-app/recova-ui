import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/features/community/data/repositories/community_repository_impl.dart';
import 'package:recova/features/community/domain/repositories/community_repository.dart';
import 'package:recova/models/post_model.dart';

part 'community_state.dart';

/// Cubit managing state for peer community discussions, post creation,
/// and atomic optimistic like toggle interactions.
class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository _communityRepository;
  final Set<String> _pendingLikePostIds = <String>{};
  List<Post> _cachedPosts = const <Post>[];

  CommunityCubit({CommunityRepository? communityRepository})
    : _communityRepository = communityRepository ?? CommunityRepositoryImpl(),
      super(CommunityInitial());

  List<Post> get cachedPosts => _cachedPosts;

  Future<void> fetchPosts({String? category}) async {
    try {
      emit(CommunityLoading());
      final posts = await _communityRepository.getPosts(category: category);
      _cachedPosts = posts;
      emit(CommunityLoadSuccess(posts));
    } catch (e) {
      emit(CommunityLoadFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String category,
  }) async {
    emit(CommunitySubmitting(_cachedPosts));
    try {
      await _communityRepository.createPost(
        title: title,
        content: content,
        category: category,
      );
      emit(CommunitySubmitSuccess(_cachedPosts));
      await fetchPosts();
    } catch (e) {
      emit(
        CommunitySubmitFailure(
          e.toString().replaceFirst('Exception: ', ''),
          _cachedPosts,
        ),
      );
    }
  }

  /// Atomically toggles like status for a community post.
  ///
  /// Applies an optimistic update immediately, invokes the backend POST toggle,
  /// synchronizes with the server-returned `liked_count` and `is_liked`, and in case
  /// of failure reverts strictly the targeted post in the current state to prevent
  /// race-condition state overwrite across concurrent toggles.
  Future<void> toggleLike(String postId) async {
    final currentState = state;
    if (currentState is! CommunityLoadSuccess) return;

    if (_pendingLikePostIds.contains(postId)) return;
    _pendingLikePostIds.add(postId);

    try {
      final postIndex = currentState.posts.indexWhere((p) => p.id == postId);
      if (postIndex == -1) return;

      final targetPost = currentState.posts[postIndex];
      final wasLiked = targetPost.isLiked;
      final originalCount = targetPost.likeCount;

      // 1. Optimistic UI update
      final optimisticPost = targetPost.copyWith(
        isLiked: !wasLiked,
        likeCount:
            wasLiked
                ? (originalCount > 0 ? originalCount - 1 : 0)
                : originalCount + 1,
      );

      final updatedPosts = List<Post>.from(currentState.posts);
      updatedPosts[postIndex] = optimisticPost;
      _cachedPosts = updatedPosts;
      emit(CommunityLoadSuccess(updatedPosts));

      // 2. Remote atomic toggle call
      try {
        final likeResult = await _communityRepository.toggleLike(postId);

        // 3. Synchronize with server payload on the LATEST state to avoid wiping concurrent updates
        final latestState = state;
        if (latestState is CommunityLoadSuccess) {
          final latestIndex = latestState.posts.indexWhere(
            (p) => p.id == postId,
          );
          if (latestIndex != -1) {
            final currentPost = latestState.posts[latestIndex];
            final syncedPost = currentPost.copyWith(
              isLiked: likeResult.isLiked,
              likeCount: likeResult.likedCount,
            );
            final syncedPosts = List<Post>.from(latestState.posts);
            syncedPosts[latestIndex] = syncedPost;
            _cachedPosts = syncedPosts;
            emit(CommunityLoadSuccess(syncedPosts));
          }
        } else {
          final cachedIndex = _cachedPosts.indexWhere((p) => p.id == postId);
          if (cachedIndex != -1) {
            final currentCached = _cachedPosts[cachedIndex];
            final syncedCached = currentCached.copyWith(
              isLiked: likeResult.isLiked,
              likeCount: likeResult.likedCount,
            );
            final newCached = List<Post>.from(_cachedPosts);
            newCached[cachedIndex] = syncedCached;
            _cachedPosts = newCached;
          }
        }
      } catch (e) {
        // 4. Revert ONLY the targeted post within the LATEST state to avoid overwriting concurrent mutations
        final latestState = state;
        if (latestState is CommunityLoadSuccess) {
          final latestIndex = latestState.posts.indexWhere(
            (p) => p.id == postId,
          );
          if (latestIndex != -1) {
            final currentPost = latestState.posts[latestIndex];
            final revertedPost = currentPost.copyWith(
              isLiked: wasLiked,
              likeCount: originalCount,
            );
            final revertedPosts = List<Post>.from(latestState.posts);
            revertedPosts[latestIndex] = revertedPost;
            _cachedPosts = revertedPosts;
            emit(CommunityLoadSuccess(revertedPosts));
          }
        } else {
          final cachedIndex = _cachedPosts.indexWhere((p) => p.id == postId);
          if (cachedIndex != -1) {
            final currentCached = _cachedPosts[cachedIndex];
            final revertedCached = currentCached.copyWith(
              isLiked: wasLiked,
              likeCount: originalCount,
            );
            final newCached = List<Post>.from(_cachedPosts);
            newCached[cachedIndex] = revertedCached;
            _cachedPosts = newCached;
          }
        }
      }
    } finally {
      _pendingLikePostIds.remove(postId);
    }
  }
}
