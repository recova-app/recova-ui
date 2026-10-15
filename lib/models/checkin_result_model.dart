import 'package:recova/models/statistics_model.dart';

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

Map<String, dynamic>? _asNullableMap(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

bool _parseBool(dynamic value, {bool defaultValue = true}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return defaultValue;
}

class RoutineCheckInData {
  final String id;
  final String userId;
  final String checkInDate;
  final String checkInDayName;
  final String mood;
  final bool isSuccessful;
  final String? commitment;
  final List<String> relapseTrigger;
  final DateTime? createdAt;

  RoutineCheckInData({
    required this.id,
    required this.userId,
    required this.checkInDate,
    required this.checkInDayName,
    required this.mood,
    required this.isSuccessful,
    this.commitment,
    this.relapseTrigger = const [],
    this.createdAt,
  });

  factory RoutineCheckInData.fromJson(Map<String, dynamic> json) {
    return RoutineCheckInData(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      checkInDate:
          (json['check_in_date'] ?? json['checkInDate'] ?? '').toString(),
      checkInDayName:
          (json['check_in_day_name'] ?? json['checkInDayName'] ?? '')
              .toString(),
      mood: (json['mood'] ?? '').toString(),
      isSuccessful: _parseBool(json['is_successful'] ?? json['isSuccessful']),
      commitment: json['commitment'],
      relapseTrigger:
          (json['relapse_trigger'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'check_in_date': checkInDate,
      'check_in_day_name': checkInDayName,
      'mood': mood,
      'is_successful': isSuccessful,
      'commitment': commitment,
      'relapse_trigger': relapseTrigger,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class RoutineRelapseData {
  final String id;
  final String userId;
  final String relapseDate;
  final String relapseDayName;
  final String? checkInId;
  final String mood;
  final String? commitment;
  final List<String> relapseTrigger;
  final DateTime? createdAt;

  RoutineRelapseData({
    required this.id,
    required this.userId,
    required this.relapseDate,
    required this.relapseDayName,
    this.checkInId,
    required this.mood,
    this.commitment,
    this.relapseTrigger = const [],
    this.createdAt,
  });

  factory RoutineRelapseData.fromJson(Map<String, dynamic> json) {
    return RoutineRelapseData(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      relapseDate:
          (json['relapse_date'] ?? json['relapseDate'] ?? '').toString(),
      relapseDayName:
          (json['relapse_day_name'] ?? json['relapseDayName'] ?? '').toString(),
      checkInId: json['check_in_id'] ?? json['checkInId'],
      mood: (json['mood'] ?? '').toString(),
      commitment: json['commitment'],
      relapseTrigger:
          (json['relapse_trigger'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'relapse_date': relapseDate,
      'relapse_day_name': relapseDayName,
      'check_in_id': checkInId,
      'mood': mood,
      'commitment': commitment,
      'relapse_trigger': relapseTrigger,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class RoutineRelapseSolutionData {
  final String title;
  final String analysis;
  final String summary;
  final DateTime? generatedAt;

  RoutineRelapseSolutionData({
    required this.title,
    required this.analysis,
    required this.summary,
    this.generatedAt,
  });

  factory RoutineRelapseSolutionData.fromJson(Map<String, dynamic> json) {
    return RoutineRelapseSolutionData(
      title: (json['title'] ?? '').toString(),
      analysis: (json['analysis'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      generatedAt:
          json['generated_at'] != null
              ? DateTime.tryParse(json['generated_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'analysis': analysis,
      'summary': summary,
      'generated_at': generatedAt?.toIso8601String(),
    };
  }
}

class RoutineCheckInResponseData {
  final RoutineCheckInData checkIn;
  final Statistics statistics;
  final RoutineRelapseSolutionData? relapseSolution;

  RoutineCheckInResponseData({
    required this.checkIn,
    required this.statistics,
    this.relapseSolution,
  });

  factory RoutineCheckInResponseData.fromJson(Map<String, dynamic> json) {
    final statsMap = _asNullableMap(json['statistics']);
    final solutionMap = _asNullableMap(json['relapse_solution']);
    return RoutineCheckInResponseData(
      checkIn: RoutineCheckInData.fromJson(_asMap(json['check_in'])),
      statistics:
          statsMap != null
              ? Statistics.fromJson(statsMap)
              : Statistics(
                currentStreak: 0,
                longestStreak: 0,
                totalCheckins: 0,
                streakCalendar: const [],
              ),
      relapseSolution:
          solutionMap != null
              ? RoutineRelapseSolutionData.fromJson(solutionMap)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'check_in': checkIn.toJson(),
      'statistics': statistics.toJson(),
      'relapse_solution': relapseSolution?.toJson(),
    };
  }
}

class RoutineRelapseResponseData {
  final RoutineRelapseData relapse;
  final Statistics statistics;
  final RoutineRelapseSolutionData? relapseSolution;

  RoutineRelapseResponseData({
    required this.relapse,
    required this.statistics,
    this.relapseSolution,
  });

  factory RoutineRelapseResponseData.fromJson(Map<String, dynamic> json) {
    final statsMap = _asNullableMap(json['statistics']);
    final solutionMap = _asNullableMap(json['relapse_solution']);
    return RoutineRelapseResponseData(
      relapse: RoutineRelapseData.fromJson(_asMap(json['relapse'])),
      statistics:
          statsMap != null
              ? Statistics.fromJson(statsMap)
              : Statistics(
                currentStreak: 0,
                longestStreak: 0,
                totalCheckins: 0,
                streakCalendar: const [],
              ),
      relapseSolution:
          solutionMap != null
              ? RoutineRelapseSolutionData.fromJson(solutionMap)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relapse': relapse.toJson(),
      'statistics': statistics.toJson(),
      'relapse_solution': relapseSolution?.toJson(),
    };
  }
}

class CheckInResult {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final RoutineCheckInData? checkIn;
  final RoutineRelapseData? relapse;
  final Statistics? statistics;
  final RoutineRelapseSolutionData? relapseSolution;

  CheckInResult({
    required this.id,
    DateTime? startDate,
    this.endDate,
    this.isActive = true,
    this.checkIn,
    this.relapse,
    this.statistics,
    this.relapseSolution,
  }) : startDate = startDate ?? DateTime.now();

  factory CheckInResult.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('check_in')) {
      final checkInData = RoutineCheckInData.fromJson(_asMap(json['check_in']));
      final statsMap = _asNullableMap(json['statistics']);
      final solutionMap = _asNullableMap(json['relapse_solution']);
      final stats = statsMap != null ? Statistics.fromJson(statsMap) : null;
      final solution =
          solutionMap != null
              ? RoutineRelapseSolutionData.fromJson(solutionMap)
              : null;
      return CheckInResult(
        id: checkInData.id,
        startDate:
            checkInData.createdAt ??
            DateTime.tryParse(checkInData.checkInDate) ??
            DateTime.now(),
        isActive: checkInData.isSuccessful,
        checkIn: checkInData,
        statistics: stats,
        relapseSolution: solution,
      );
    }

    if (json.containsKey('relapse')) {
      final relapseData = RoutineRelapseData.fromJson(_asMap(json['relapse']));
      final statsMap = _asNullableMap(json['statistics']);
      final solutionMap = _asNullableMap(json['relapse_solution']);
      final stats = statsMap != null ? Statistics.fromJson(statsMap) : null;
      final solution =
          solutionMap != null
              ? RoutineRelapseSolutionData.fromJson(solutionMap)
              : null;
      return CheckInResult(
        id: relapseData.id,
        startDate:
            relapseData.createdAt ??
            DateTime.tryParse(relapseData.relapseDate) ??
            DateTime.now(),
        isActive: false,
        relapse: relapseData,
        statistics: stats,
        relapseSolution: solution,
      );
    }

    // Legacy fallback
    return CheckInResult(
      id: (json['id'] ?? '').toString(),
      startDate:
          json['startDate'] != null
              ? DateTime.tryParse(json['startDate'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      endDate:
          json['endDate'] != null
              ? DateTime.tryParse(json['endDate'].toString())
              : null,
      isActive: _parseBool(json['isActive']),
    );
  }
}
