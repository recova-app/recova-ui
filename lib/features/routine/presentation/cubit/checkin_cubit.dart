import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/features/home/presentation/cubit/home_cubit.dart';
import 'package:recova/features/routine/data/repositories/routine_repository_impl.dart';
import 'package:recova/features/routine/domain/repositories/routine_repository.dart';
import 'package:recova/models/checkin_result_model.dart';

part 'checkin_state.dart';

class CheckinCubit extends Cubit<CheckinState> {
  final HomeCubit? _homeCubit;
  final RoutineRepository _routineRepository;

  CheckinCubit({HomeCubit? homeCubit, RoutineRepository? routineRepository})
    : _homeCubit = homeCubit,
      _routineRepository = routineRepository ?? RoutineRepositoryImpl(),
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
      final result = await _routineRepository.checkIn(
        content: content,
        mood: mood,
        commitment: commitment,
      );
      emit(CheckinSuccess(result));

      // Re-fetch home data from API so the home page reflects the latest state
      _homeCubit?.fetchHomeData();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(CheckinFailure(errorMessage));
    }
  }

  void resetState() {
    emit(CheckinInitial());
  }
}
