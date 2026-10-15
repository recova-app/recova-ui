import 'package:equatable/equatable.dart';

/// Top-level successful response envelope matching OpenAPI `SuccessEnvelope`.
class SuccessEnvelope<T> extends Equatable {
  const SuccessEnvelope({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
  });

  final bool success;
  final String message;
  final T data;
  final SuccessMeta? meta;

  factory SuccessEnvelope.fromJson(
    Map<String, dynamic> json, [
    T Function(dynamic rawData)? fromJsonT,
  ]) {
    final rawData = json['data'];
    final data = fromJsonT != null ? fromJsonT(rawData) : (rawData as T);
    return SuccessEnvelope<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: data,
      meta:
          json['meta'] is Map<String, dynamic>
              ? SuccessMeta.fromJson(json['meta'] as Map<String, dynamic>)
              : (json['meta'] is Map
                  ? SuccessMeta.fromJson(
                    Map<String, dynamic>.from(json['meta'] as Map),
                  )
                  : null),
    );
  }

  Map<String, dynamic> toJson([Object? Function(T value)? toJsonT]) {
    return {
      'success': success,
      'message': message,
      'data': toJsonT != null ? toJsonT(data) : data,
      if (meta != null) 'meta': meta!.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, data, meta];
}

/// Top-level error response envelope matching OpenAPI `ErrorEnvelope`.
class ErrorEnvelope extends Equatable {
  const ErrorEnvelope({
    required this.success,
    required this.message,
    this.data,
    required this.error,
  });

  final bool success;
  final String message;
  final dynamic data;
  final ErrorPayload error;

  factory ErrorEnvelope.fromJson(Map<String, dynamic> json) {
    return ErrorEnvelope(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Terjadi kesalahan pada server',
      data: json['data'],
      error:
          json['error'] is Map<String, dynamic>
              ? ErrorPayload.fromJson(json['error'] as Map<String, dynamic>)
              : (json['error'] is Map
                  ? ErrorPayload.fromJson(
                    Map<String, dynamic>.from(json['error'] as Map),
                  )
                  : const ErrorPayload(code: 'UNKNOWN_ERROR', requestId: '')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'error': error.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, data, error];
}

/// Payload object within ErrorEnvelope.
class ErrorPayload extends Equatable {
  const ErrorPayload({
    required this.code,
    required this.requestId,
    this.details,
    this.validationErrors = const [],
  });

  final String code;
  final String requestId;
  final dynamic details;
  final List<ValidationErrorDetail> validationErrors;

  factory ErrorPayload.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['details'];
    final validationErrors = <ValidationErrorDetail>[];
    if (rawDetails is List) {
      for (final item in rawDetails) {
        if (item is Map<String, dynamic>) {
          validationErrors.add(ValidationErrorDetail.fromJson(item));
        } else if (item is Map) {
          validationErrors.add(
            ValidationErrorDetail.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return ErrorPayload(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      requestId: json['request_id'] as String? ?? '',
      details: rawDetails,
      validationErrors: List.unmodifiable(validationErrors),
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'request_id': requestId, 'details': details};
  }

  @override
  List<Object?> get props => [code, requestId, details, validationErrors];
}

/// Validation error entry matching OpenAPI `ValidationErrorDetail`.
class ValidationErrorDetail extends Equatable {
  const ValidationErrorDetail({required this.field, required this.message});

  final String field;
  final String message;

  factory ValidationErrorDetail.fromJson(Map<String, dynamic> json) {
    return ValidationErrorDetail(
      field: json['field'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'field': field, 'message': message};
  }

  @override
  List<Object?> get props => [field, message];
}

/// Metadata attached to successful response envelopes matching OpenAPI `SuccessMeta`.
class SuccessMeta extends Equatable {
  const SuccessMeta({this.pagination, this.trace});

  final PaginationMeta? pagination;
  final TraceMeta? trace;

  factory SuccessMeta.fromJson(Map<String, dynamic> json) {
    return SuccessMeta(
      pagination:
          json['pagination'] is Map<String, dynamic>
              ? PaginationMeta.fromJson(
                json['pagination'] as Map<String, dynamic>,
              )
              : (json['pagination'] is Map
                  ? PaginationMeta.fromJson(
                    Map<String, dynamic>.from(json['pagination'] as Map),
                  )
                  : null),
      trace:
          json['trace'] is Map<String, dynamic>
              ? TraceMeta.fromJson(json['trace'] as Map<String, dynamic>)
              : (json['trace'] is Map
                  ? TraceMeta.fromJson(
                    Map<String, dynamic>.from(json['trace'] as Map),
                  )
                  : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (pagination != null) 'pagination': pagination!.toJson(),
      if (trace != null) 'trace': trace!.toJson(),
    };
  }

  @override
  List<Object?> get props => [pagination, trace];
}

/// Pagination information within `SuccessMeta`.
class PaginationMeta extends Equatable {
  const PaginationMeta({this.limit, this.total, this.hasMore});

  final int? limit;
  final int? total;
  final bool? hasMore;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      limit: json['limit'] as int?,
      total: json['total'] as int?,
      hasMore: json['has_more'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (limit != null) 'limit': limit,
      if (total != null) 'total': total,
      if (hasMore != null) 'has_more': hasMore,
    };
  }

  @override
  List<Object?> get props => [limit, total, hasMore];
}

/// Request trace information within `SuccessMeta`.
class TraceMeta extends Equatable {
  const TraceMeta({this.requestId, this.timestamp});

  final String? requestId;
  final String? timestamp;

  factory TraceMeta.fromJson(Map<String, dynamic> json) {
    return TraceMeta(
      requestId: json['request_id'] as String?,
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (requestId != null) 'request_id': requestId,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [requestId, timestamp];
}
