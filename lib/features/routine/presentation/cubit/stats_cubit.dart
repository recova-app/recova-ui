import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recova/features/routine/data/repositories/routine_repository_impl.dart';
import 'package:recova/features/routine/domain/repositories/routine_repository.dart';
import 'package:recova/models/relapse_statistics_model.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final RoutineRepository _routineRepository;

  StatsCubit({RoutineRepository? routineRepository})
    : _routineRepository = routineRepository ?? RoutineRepositoryImpl(),
      super(StatsInitial());

  Future<void> fetchStats() async {
    emit(StatsLoading());
    try {
      final data = await _routineRepository.getRelapseStatistics();
      emit(StatsLoadSuccess(data: data));
    } catch (e) {
      emit(StatsLoadFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
