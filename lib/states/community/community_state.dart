import 'package:recova/models/post_model.dart';

abstract class CommunityState {
  const CommunityState();
}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoadSuccess extends CommunityState {
  final List<Post> posts;

  const CommunityLoadSuccess(this.posts);
}

class CommunityLoadFailure extends CommunityState {
  final String error;

  const CommunityLoadFailure(this.error);
}

class CommunitySubmitting extends CommunityState {}

class CommunitySubmitSuccess extends CommunityState {}

class CommunitySubmitFailure extends CommunityState {
  final String error;
  const CommunitySubmitFailure(this.error);
}
