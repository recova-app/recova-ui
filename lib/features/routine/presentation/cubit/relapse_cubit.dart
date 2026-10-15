import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/features/home/presentation/cubit/home_cubit.dart';
import 'package:recova/features/routine/data/repositories/routine_repository_impl.dart';
import 'package:recova/features/routine/domain/repositories/routine_repository.dart';
import 'package:recova/models/checkin_result_model.dart';

part 'relapse_state.dart';

class RelapseCubit extends Cubit<RelapseState> {
  final HomeCubit? _homeCubit;
  final RoutineRepository _routineRepository;

  RelapseCubit({HomeCubit? homeCubit, RoutineRepository? routineRepository})
    : _homeCubit = homeCubit,
      _routineRepository = routineRepository ?? RoutineRepositoryImpl(),
      super(RelapseInitial());

  Future<void> submitRelapse({
    required String mood,
    required List<String> relapseTriggers,
    required String commitment,
    String content = 'Relapse report',
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
      // 1. Record relapse trigger via repository
      final relapseResult = await _routineRepository.submitRelapse(
        mood: mood,
        relapseTriggers: relapseTriggers,
        commitment: commitment,
        content: content,
      );

      // 2. Fetch personalized AI recovery advice
      RoutineRelapseSolutionData? aiSolution;
      try {
        aiSolution = await _routineRepository.getRelapseSolution(
          mood: mood,
          relapseTriggers: relapseTriggers,
          commitment: commitment,
        );
      } catch (_) {
        // Graceful fallback when AI service is unavailable or returns downstream error
        aiSolution =
            relapseResult.relapseSolution ??
            RoutineRelapseSolutionData(
              title: 'Langkah Pemulihan',
              analysis:
                  'Relapse telah dicatat. Ambil jeda sejenak untuk menenangkan diri.',
              summary:
                  'Fokus pada stabilisasi emosi, hindari pemicu saat ini, dan jaga komitmen pemulihan.',
              generatedAt: DateTime.now(),
            );
      }

      final finalResult = relapseResult.copyWith(relapseSolution: aiSolution);

      emit(RelapseSuccess(finalResult, aiSolution: aiSolution));

      // 3. Re-fetch home data so the dashboard reflects the reset
      _homeCubit?.fetchHomeData();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(RelapseFailure(errorMessage));
    }
  }

  void resetState() {
    emit(RelapseInitial());
  }
}
