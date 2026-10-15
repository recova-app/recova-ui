import 'package:recova/core/network/api_client.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:recova/models/statistics_model.dart';

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

/// Remote data source contract for recovery routine and relapse operations.
abstract class RoutineRemoteDataSource {
  /// Save user daily check-in (POST /api/v1/routine/checkin)
  Future<RoutineCheckInResponseData> checkIn({
    required String content,
    required String mood,
    String commitment = '',
  });

  /// Get user check-in statistics (GET /api/v1/routine/statistics)
  Future<Statistics> getStatistics();

  /// Save user relapse trigger for current UTC day (POST /api/v1/routine/relapses)
  Future<RoutineRelapseResponseData> submitRelapse({
    required String mood,
    required List<String> relapseTriggers,
    String commitment = '',
    String content = 'Relapse report',
  });

  /// Get complete relapse statistics with UTC hour analysis (GET /api/v1/routine/relapses/statistics)
  Future<RelapseStatisticsResponse> getRelapseStatistics();

  /// Generate AI relapse recovery solution (POST /api/v1/ai/relapse-solution)
  Future<RoutineRelapseSolutionData> getRelapseSolution({
    required String mood,
    List<String> relapseTriggers = const [],
    String commitment = '',
  });
}

/// Implementation of [RoutineRemoteDataSource] backed by injectable [ApiClient].
class RoutineRemoteDataSourceImpl implements RoutineRemoteDataSource {
  RoutineRemoteDataSourceImpl({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<RoutineCheckInResponseData> checkIn({
    required String content,
    required String mood,
    String commitment = '',
  }) async {
    final payload = <String, dynamic>{
      'mood': mood,
      'is_successful': true,
      'commitment': commitment,
      'content': content,
    };

    final response = await _apiClient.post<RoutineCheckInResponseData>(
      '/routine/checkin',
      data: payload,
      fromJson:
          (rawData) => RoutineCheckInResponseData.fromJson(_asMap(rawData)),
    );

    return response.data;
  }

  @override
  Future<Statistics> getStatistics() async {
    final response = await _apiClient.get<Statistics>(
      '/routine/statistics',
      fromJson: (rawData) => Statistics.fromJson(_asMap(rawData)),
    );

    return response.data;
  }

  @override
  Future<RoutineRelapseResponseData> submitRelapse({
    required String mood,
    required List<String> relapseTriggers,
    String commitment = '',
    String content = 'Relapse report',
  }) async {
    final payload = <String, dynamic>{
      'mood': mood,
      'relapse_trigger': relapseTriggers,
      'commitment': commitment,
      'content': content,
    };

    final response = await _apiClient.post<RoutineRelapseResponseData>(
      '/routine/relapses',
      data: payload,
      fromJson:
          (rawData) => RoutineRelapseResponseData.fromJson(_asMap(rawData)),
    );

    return response.data;
  }

  @override
  Future<RelapseStatisticsResponse> getRelapseStatistics() async {
    final response = await _apiClient.get<RelapseStatisticsResponse>(
      '/routine/relapses/statistics',
      fromJson:
          (rawData) => RelapseStatisticsResponse.fromJson(_asMap(rawData)),
    );

    return response.data;
  }

  @override
  Future<RoutineRelapseSolutionData> getRelapseSolution({
    required String mood,
    List<String> relapseTriggers = const [],
    String commitment = '',
  }) async {
    final payload = <String, dynamic>{'mood': mood};
    if (relapseTriggers.isNotEmpty) {
      payload['relapse_trigger'] = relapseTriggers;
    }
    if (commitment.isNotEmpty) {
      payload['commitment'] = commitment;
    }

    final response = await _apiClient.post<RoutineRelapseSolutionData>(
      '/ai/relapse-solution',
      data: payload,
      fromJson:
          (rawData) => RoutineRelapseSolutionData.fromJson(_asMap(rawData)),
    );

    return response.data;
  }
}
