import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/services/api_service.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:equatable/equatable.dart';

part 'checkin_state.dart';

class CheckinCubit extends Cubit<CheckinState> {
  final HomeCubit _homeCubit;

  CheckinCubit({required HomeCubit homeCubit})
      : _homeCubit = homeCubit,
        super(CheckinInitial());

  Future<void> performCheckIn({
    required String content,
    String mood = 'bahagia',
    String commitment = '',
  }) async {
    if (content.isEmpty) {
      emit(const CheckinFailure("Isi jurnal terlebih dahulu"));
      return;
    }

    emit(CheckinLoading());
    try {
      final result = await ApiService.checkIn(
        content: content,
        mood: mood,
        commitment: commitment,
      );
      emit(CheckinSuccess(result));

      // Re-fetch home data from API so the home page reflects the latest state
      _homeCubit.fetchHomeData();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(CheckinFailure(errorMessage));
    }
  }

  void resetState() {
    emit(CheckinInitial());
  }
}