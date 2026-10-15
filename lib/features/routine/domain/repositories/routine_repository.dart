import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:recova/models/statistics_model.dart';

/// Abstract repository defining domain operations for recovery routine,
/// check-ins, relapse recording, and AI relapse solutions.
abstract class RoutineRepository {
  /// Save user daily check-in (POST /api/v1/routine/checkin)
  Future<CheckInResult> checkIn({
    required String content,
    required String mood,
    String commitment = '',
  });

  /// Get user check-in statistics (GET /api/v1/routine/statistics)
  Future<Statistics> getStatistics();

  /// Save user relapse trigger for current UTC day (POST /api/v1/routine/relapses)
  Future<CheckInResult> submitRelapse({
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
