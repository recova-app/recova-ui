part of 'checkin_cubit.dart';

abstract class CheckinState extends Equatable {
  const CheckinState();

  @override
  List<Object> get props => [];
}

class CheckinInitial extends CheckinState {}

class CheckinLoading extends CheckinState {}

class CheckinSuccess extends CheckinState {
  final CheckInResult result;
  const CheckinSuccess(this.result);
  @override
  List<Object> get props => [result];
}

class CheckinFailure extends CheckinState {
  final String error;
  const CheckinFailure(this.error);
  @override
  List<Object> get props => [error];
}
