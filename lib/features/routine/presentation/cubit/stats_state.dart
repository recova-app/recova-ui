part of 'stats_cubit.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoadSuccess extends StatsState {
  final RelapseStatisticsResponse data;

  const StatsLoadSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class StatsLoadFailure extends StatsState {
  final String error;

  const StatsLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
