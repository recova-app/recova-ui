part of 'education_cubit.dart';

abstract class EducationState extends Equatable {
  const EducationState();

  @override
  List<Object> get props => [];
}

class EducationInitial extends EducationState {}

class EducationLoading extends EducationState {}

class EducationLoadSuccess extends EducationState {
  final List<EducationContent> contents;
  const EducationLoadSuccess(this.contents);
  @override
  List<Object> get props => [contents];
}

class EducationLoadFailure extends EducationState {
  final String error;
  const EducationLoadFailure(this.error);
  @override
  List<Object> get props => [error];
}
