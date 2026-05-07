import 'package:get/get.dart';
import 'package:recova/services/api_service.dart';

import 'package:recova/states/checkin/checkin_state.dart';

export 'package:recova/states/checkin/checkin_state.dart';

class CheckinController extends GetxController {
  final Rx<CheckinState> state = Rx<CheckinState>(CheckinInitial());

  Future<void> performCheckIn({required String journal}) async {
    if (journal.isEmpty) {
      state.value = const CheckinFailure("Isi jurnal terlebih dahulu");
      return;
    }

    state.value = CheckinLoading();
    try {
      final result = await ApiService.checkIn(journal: journal);
      state.value = CheckinSuccess(result);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state.value = CheckinFailure(errorMessage);
    }
  }

  void resetState() {
    state.value = CheckinInitial();
  }
}
