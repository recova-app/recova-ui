import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/services/api_service.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:equatable/equatable.dart';

part 'relapse_state.dart';

class RelapseCubit extends Cubit<RelapseState> {
  final HomeCubit _homeCubit;

  RelapseCubit({required HomeCubit homeCubit})
      : _homeCubit = homeCubit,
        super(RelapseInitial());

  Future<void> submitRelapse({
    required String mood,
    required List<String> relapseTriggers,
    required String commitment,
  }) async {
    if (mood.isEmpty) {
      emit(const RelapseFailure("Pilih mood kamu terlebih dahulu"));
      return;
    }
    if (relapseTriggers.isEmpty) {
      emit(const RelapseFailure("Pilih minimal satu pemicu relapse"));
      return;
    }
    if (commitment.isEmpty) {
      emit(const RelapseFailure("Tulis pesan komitmen kamu"));
      return;
    }

    emit(RelapseLoading());
    try {
      final result = await ApiService.relapse(
        content: 'Relapse report',
        mood: mood,
        commitment: commitment,
        relapseTrigger: relapseTriggers,
      );
      emit(RelapseSuccess(result));

      // Re-fetch home data so the home page reflects the reset
      _homeCubit.fetchHomeData();
    } catch (e) {
      print(e);
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(RelapseFailure(errorMessage));
    }
  }

  void resetState() {
    emit(RelapseInitial());
  }
}
