part of 'community_cubit.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();

  List<Post> get posts => const <Post>[];

  @override
  List<Object> get props => [];
}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoadSuccess extends CommunityState {
  final List<Post> posts;

  const CommunityLoadSuccess(this.posts);

  @override
  List<Object> get props => [posts];
}

class CommunityLoadFailure extends CommunityState {
  final String error;

  const CommunityLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}

class CommunitySubmitting extends CommunityState {
  final List<Post> previousPosts;

  const CommunitySubmitting(this.previousPosts);

  @override
  List<Post> get posts => previousPosts;

  @override
  List<Object> get props => [previousPosts];
}

class CommunitySubmitSuccess extends CommunityState {
  final List<Post> previousPosts;

  const CommunitySubmitSuccess(this.previousPosts);

  @override
  List<Post> get posts => previousPosts;

  @override
  List<Object> get props => [previousPosts];
}

class CommunitySubmitFailure extends CommunityState {
  final String error;
  final List<Post> previousPosts;

  const CommunitySubmitFailure(this.error, this.previousPosts);

  @override
  List<Post> get posts => previousPosts;

  @override
  List<Object> get props => [error, previousPosts];
}
