import 'package:recova/models/checkin_result_model.dart';

abstract class CheckinState {
  const CheckinState();
}

class CheckinInitial extends CheckinState {}

class CheckinLoading extends CheckinState {}

class CheckinSuccess extends CheckinState {
  final CheckInResult result;
  const CheckinSuccess(this.result);
}

class CheckinFailure extends CheckinState {
  final String error;
  const CheckinFailure(this.error);
}
