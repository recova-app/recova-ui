import 'package:get/get.dart';
import 'package:recova/services/api_service.dart';

import 'package:recova/states/education/education_state.dart';

export 'package:recova/states/education/education_state.dart';

class EducationController extends GetxController {
  final Rx<EducationState> state = Rx<EducationState>(EducationInitial());

  Future<void> fetchEducationContents() async {
    try {
      state.value = EducationLoading();
      final contents = await ApiService.getEducationContents();
      state.value = EducationLoadSuccess(contents);
    } catch (e) {
      state.value = EducationLoadFailure(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
