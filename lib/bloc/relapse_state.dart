part of 'relapse_cubit.dart';

abstract class RelapseState extends Equatable {
  const RelapseState();

  @override
  List<Object> get props => [];
}

class RelapseInitial extends RelapseState {}

class RelapseLoading extends RelapseState {}

class RelapseSuccess extends RelapseState {
  final CheckInResult result;
  const RelapseSuccess(this.result);
  @override
  List<Object> get props => [result];
}

class RelapseFailure extends RelapseState {
  final String error;
  const RelapseFailure(this.error);
  @override
  List<Object> get props => [error];
}
