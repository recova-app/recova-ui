import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/user_model.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoadSuccess extends HomeState {
  final User user;
  final Statistics statistics;

  const HomeLoadSuccess({required this.user, required this.statistics});
}

class HomeLoadFailure extends HomeState {
  final String error;

  const HomeLoadFailure(this.error);
}
