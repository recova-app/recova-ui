import 'package:recova/models/education_model.dart';

abstract class EducationState {
  const EducationState();
}

class EducationInitial extends EducationState {}

class EducationLoading extends EducationState {}

class EducationLoadSuccess extends EducationState {
  final List<EducationContent> contents;
  const EducationLoadSuccess(this.contents);
}

class EducationLoadFailure extends EducationState {
  final String error;
  const EducationLoadFailure(this.error);
}
