import 'package:recova/features/routine/data/datasources/routine_remote_data_source.dart';
import 'package:recova/features/routine/domain/repositories/routine_repository.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:recova/models/statistics_model.dart';

/// Implementation of [RoutineRepository] orchestrating the [RoutineRemoteDataSource].
class RoutineRepositoryImpl implements RoutineRepository {
  RoutineRepositoryImpl({RoutineRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? RoutineRemoteDataSourceImpl();

  final RoutineRemoteDataSource _remoteDataSource;

  @override
  Future<CheckInResult> checkIn({
    required String content,
    required String mood,
    String commitment = '',
  }) async {
    final response = await _remoteDataSource.checkIn(
      content: content,
      mood: mood,
      commitment: commitment,
    );
    return CheckInResult.fromCheckInResponse(response);
  }

  @override
  Future<Statistics> getStatistics() async {
    return _remoteDataSource.getStatistics();
  }

  @override
  Future<CheckInResult> submitRelapse({
    required String mood,
    required List<String> relapseTriggers,
    String commitment = '',
    String content = 'Relapse report',
  }) async {
    final response = await _remoteDataSource.submitRelapse(
      mood: mood,
      relapseTriggers: relapseTriggers,
      commitment: commitment,
      content: content,
    );
    return CheckInResult.fromRelapseResponse(response);
  }

  @override
  Future<RelapseStatisticsResponse> getRelapseStatistics() async {
    return _remoteDataSource.getRelapseStatistics();
  }

  @override
  Future<RoutineRelapseSolutionData> getRelapseSolution({
    required String mood,
    List<String> relapseTriggers = const [],
    String commitment = '',
  }) async {
    return _remoteDataSource.getRelapseSolution(
      mood: mood,
      relapseTriggers: relapseTriggers,
      commitment: commitment,
    );
  }
}
