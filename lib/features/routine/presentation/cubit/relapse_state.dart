part of 'relapse_cubit.dart';

abstract class RelapseState extends Equatable {
  const RelapseState();

  @override
  List<Object?> get props => [];
}

class RelapseInitial extends RelapseState {}

class RelapseLoading extends RelapseState {}

class RelapseSuccess extends RelapseState {
  final CheckInResult result;
  final RoutineRelapseSolutionData? aiSolution;

  const RelapseSuccess(this.result, {this.aiSolution});

  @override
  List<Object?> get props => [result, aiSolution];
}

class RelapseFailure extends RelapseState {
  final String error;
  const RelapseFailure(this.error);

  @override
  List<Object?> get props => [error];
}
