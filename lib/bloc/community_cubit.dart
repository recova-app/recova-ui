import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recova/models/post_model.dart';
import 'package:recova/services/api_service.dart';

part 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  CommunityCubit() : super(CommunityInitial());
  List<Post> _cachedPosts = const <Post>[];

  Future<void> fetchPosts({String? category}) async {
    try {
      emit(CommunityLoading());
      final posts = await ApiService.getCommunityPosts(category: category);
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
    // Emit state untuk menunjukkan proses pengiriman tanpa kehilangan data list.
    emit(CommunitySubmitting(_cachedPosts));
    try {
      await ApiService.createPost(
        title: title,
        content: content,
        category: category,
      );
      // Setelah berhasil, emit state sukses singkat lalu muat ulang list.
      emit(CommunitySubmitSuccess(_cachedPosts));
      // Kemudian, muat ulang semua postingan untuk menampilkan yang baru
      await fetchPosts();
    } catch (e) {
      // Jika gagal, emit state error
      emit(
        CommunitySubmitFailure(
          e.toString().replaceFirst('Exception: ', ''),
          _cachedPosts,
        ),
      );
    }
  }

  Future<void> toggleLike(String postId) async {
    final currentState = state;
    if (currentState is! CommunityLoadSuccess) return;

    final postIndex = currentState.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = currentState.posts[postIndex];
    final isCurrentlyLiked = post.isLiked;

    // Optimistic UI update
    final updatedPost = post.copyWith(
      isLiked: !isCurrentlyLiked,
      likeCount: isCurrentlyLiked ? post.likeCount - 1 : post.likeCount + 1,
    );

    final updatedPosts = List<Post>.from(currentState.posts);
    updatedPosts[postIndex] = updatedPost;

    emit(CommunityLoadSuccess(updatedPosts));

    // Call API
    try {
      if (isCurrentlyLiked) {
        await ApiService.unlikePost(postId);
      } else {
        await ApiService.likePost(postId);
      }
    } catch (e) {
      // If API call fails, revert the state
      final revertedPosts = List<Post>.from(currentState.posts);
      emit(CommunityLoadSuccess(revertedPosts));
      // Optionally, show an error message to the user
    }
  }
}
