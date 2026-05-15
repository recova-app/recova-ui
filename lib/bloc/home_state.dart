part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoadSuccess extends HomeState {
  final User user;
  final Statistics statistics;
  final DailyContent? dailyContent;
  final List<String> relapseCalendar;

  const HomeLoadSuccess({required this.user, required this.statistics, this.dailyContent, this.relapseCalendar = const []});

  @override
  List<Object> get props => [user, statistics, relapseCalendar, if (dailyContent != null) dailyContent!];
}

class HomeLoadFailure extends HomeState {
  final String error;

  const HomeLoadFailure(this.error);

  @override
  List<Object> get props => [error];
}