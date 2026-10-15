import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/models/education_model.dart';
import 'package:recova/services/api_service.dart';

part 'education_state.dart';

class EducationCubit extends Cubit<EducationState> {
  EducationCubit() : super(EducationInitial());

  Future<void> fetchEducationContents() async {
    try {
      emit(EducationLoading());
      final contents = await ApiService.getEducationContents();
      emit(EducationLoadSuccess(contents));
    } catch (e) {
      emit(EducationLoadFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
