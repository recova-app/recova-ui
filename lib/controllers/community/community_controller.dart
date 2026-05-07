import 'package:get/get.dart';
import 'package:recova/models/post_model.dart';
import 'package:recova/services/api_service.dart';

import 'package:recova/states/community/community_state.dart';

export 'package:recova/states/community/community_state.dart';

class CommunityController extends GetxController {
  final Rx<CommunityState> state = Rx<CommunityState>(CommunityInitial());

  Future<void> fetchPosts() async {
    try {
      state.value = CommunityLoading();
      final posts = await ApiService.getCommunityPosts();
      state.value = CommunityLoadSuccess(posts);
    } catch (e) {
      state.value = CommunityLoadFailure(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> createPost({
    required String title,
    required String content,
    required String category,
  }) async {
    state.value = CommunitySubmitting();
    try {
      await ApiService.createPost(
        title: title,
        content: content,
        category: category,
      );
      state.value = CommunitySubmitSuccess();
      await fetchPosts();
    } catch (e) {
      state.value = CommunitySubmitFailure(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> toggleLike(String postId) async {
    final currentState = state.value;
    if (currentState is! CommunityLoadSuccess) return;

    final postIndex = currentState.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final post = currentState.posts[postIndex];
    final isCurrentlyLiked = post.isLiked;

    final updatedPost = post.copyWith(
      isLiked: !isCurrentlyLiked,
      likeCount: isCurrentlyLiked ? post.likeCount - 1 : post.likeCount + 1,
    );

    final updatedPosts = List<Post>.from(currentState.posts);
    updatedPosts[postIndex] = updatedPost;

    state.value = CommunityLoadSuccess(updatedPosts);

    try {
      if (isCurrentlyLiked) {
        await ApiService.unlikePost(postId);
      } else {
        await ApiService.likePost(postId);
      }
    } catch (e) {
      final revertedPosts = List<Post>.from(currentState.posts);
      state.value = CommunityLoadSuccess(revertedPosts);
    }
  }
}
