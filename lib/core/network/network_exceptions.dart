import 'package:equatable/equatable.dart';
import 'package:recova/core/network/api_envelope.dart';

/// Base sealed exception class for all networking and HTTP communication errors.
sealed class NetworkException extends Equatable implements Exception {
  const NetworkException({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];

  @override
  String toString() => message;
}

/// Thrown when device has no internet or socket connection fails.
class ConnectionNetworkException extends NetworkException {
  const ConnectionNetworkException({
    super.message = 'Tidak ada koneksi internet. Periksa jaringan Anda.',
    super.cause,
  });
}

/// Thrown when request or response times out.
class TimeoutNetworkException extends NetworkException {
  const TimeoutNetworkException({
    super.message = 'Koneksi ke server terputus karena batas waktu habis.',
    super.cause,
  });
}

/// Thrown when response body cannot be parsed or violates contract.
class ResponseParseException extends NetworkException {
  const ResponseParseException({
    required super.message,
    this.rawBody,
    super.cause,
  });

  final String? rawBody;

  @override
  List<Object?> get props => [message, rawBody, cause];
}

/// Generic HTTP API error mapped from `ErrorEnvelope` or non-2xx status code.
class ApiException extends NetworkException {
  const ApiException({
    required super.message,
    required this.statusCode,
    this.errorCode,
    this.requestId,
    this.details,
    this.errorEnvelope,
    super.cause,
  });

  final int statusCode;
  final String? errorCode;
  final String? requestId;
  final dynamic details;
  final ErrorEnvelope? errorEnvelope;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidationError => statusCode == 422;
  bool get isRateLimited => statusCode == 429;
  bool get isServerError => statusCode >= 500;

  /// Factory constructing specific [ApiException] subclasses according to HTTP status code.
  factory ApiException.fromStatus({
    required int statusCode,
    String? message,
    String? errorCode,
    String? requestId,
    dynamic details,
    List<ValidationErrorDetail> validationErrors = const [],
    ErrorEnvelope? errorEnvelope,
    Object? cause,
  }) {
    final effectiveMessage =
        message ??
        errorEnvelope?.message ??
        'Terjadi kesalahan pada server ($statusCode)';
    final effectiveErrorCode = errorCode ?? errorEnvelope?.error.code;
    final effectiveRequestId = requestId ?? errorEnvelope?.error.requestId;
    final effectiveDetails = details ?? errorEnvelope?.error.details;
    final effectiveValidationErrors =
        validationErrors.isNotEmpty
            ? validationErrors
            : (errorEnvelope?.error.validationErrors ?? const []);

    switch (statusCode) {
      case 401:
        return UnauthorizedException(
          message: effectiveMessage,
          statusCode: statusCode,
          errorCode: effectiveErrorCode ?? 'UNAUTHENTICATED',
          requestId: effectiveRequestId,
          details: effectiveDetails,
          errorEnvelope: errorEnvelope,
          cause: cause,
        );
      case 403:
        return ForbiddenException(
          message: effectiveMessage,
          statusCode: statusCode,
          errorCode: effectiveErrorCode ?? 'FORBIDDEN',
          requestId: effectiveRequestId,
          details: effectiveDetails,
          errorEnvelope: errorEnvelope,
          cause: cause,
        );
      case 404:
        return NotFoundException(
          message: effectiveMessage,
          statusCode: statusCode,
          errorCode: effectiveErrorCode ?? 'NOT_FOUND',
          requestId: effectiveRequestId,
          details: effectiveDetails,
          errorEnvelope: errorEnvelope,
          cause: cause,
        );
      case 409:
        return ConflictException(
          message: effectiveMessage,
          statusCode: statusCode,
          errorCode: effectiveErrorCode ?? 'CONFLICT',
          requestId: effectiveRequestId,
          details: effectiveDetails,
          errorEnvelope: errorEnvelope,
          cause: cause,
        );
      case 422:
        return ValidationException(
          message: effectiveMessage,
          statusCode: statusCode,
          errorCode: effectiveErrorCode ?? 'VALIDATION_ERROR',
          requestId: effectiveRequestId,
          details: effectiveDetails,
          errors: effectiveValidationErrors,
          errorEnvelope: errorEnvelope,
          cause: cause,
        );
      case 429:
        return RateLimitedException(
          message: effectiveMessage,
          statusCode: statusCode,
          errorCode: effectiveErrorCode ?? 'RATE_LIMITED',
          requestId: effectiveRequestId,
          details: effectiveDetails,
          errorEnvelope: errorEnvelope,
          cause: cause,
        );
      default:
        if (statusCode >= 500) {
          return ServerException(
            message: effectiveMessage,
            statusCode: statusCode,
            errorCode: effectiveErrorCode ?? 'INTERNAL_ERROR',
            requestId: effectiveRequestId,
            details: effectiveDetails,
            errorEnvelope: errorEnvelope,
            cause: cause,
          );
        }
        return ApiException(
          message: effectiveMessage,
          statusCode: statusCode,
          errorCode: effectiveErrorCode,
          requestId: effectiveRequestId,
          details: effectiveDetails,
          errorEnvelope: errorEnvelope,
          cause: cause,
        );
    }
  }

  @override
  List<Object?> get props => [
    message,
    statusCode,
    errorCode,
    requestId,
    details,
    errorEnvelope,
    cause,
  ];
}

/// Thrown on HTTP 401 Unauthenticated.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Autentikasi dibutuhkan',
    super.statusCode = 401,
    super.errorCode = 'UNAUTHENTICATED',
    super.requestId,
    super.details,
    super.errorEnvelope,
    super.cause,
  });
}

/// Thrown on HTTP 403 Forbidden.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Akses ditolak',
    super.statusCode = 403,
    super.errorCode = 'FORBIDDEN',
    super.requestId,
    super.details,
    super.errorEnvelope,
    super.cause,
  });
}

/// Thrown on HTTP 404 Not Found.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Data tidak ditemukan',
    super.statusCode = 404,
    super.errorCode = 'NOT_FOUND',
    super.requestId,
    super.details,
    super.errorEnvelope,
    super.cause,
  });
}

/// Thrown on HTTP 409 Conflict.
class ConflictException extends ApiException {
  const ConflictException({
    super.message = 'Terjadi konflik data',
    super.statusCode = 409,
    super.errorCode = 'CONFLICT',
    super.requestId,
    super.details,
    super.errorEnvelope,
    super.cause,
  });
}

/// Thrown on HTTP 422 Validation Error.
class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Data yang dikirim tidak valid',
    super.statusCode = 422,
    super.errorCode = 'VALIDATION_ERROR',
    super.requestId,
    super.details,
    super.errorEnvelope,
    super.cause,
    this.errors = const [],
  });

  final List<ValidationErrorDetail> errors;

  @override
  List<Object?> get props => [...super.props, errors];
}

/// Thrown on HTTP 429 Rate Limited.
class RateLimitedException extends ApiException {
  const RateLimitedException({
    super.message = 'Terlalu banyak permintaan, coba lagi sebentar',
    super.statusCode = 429,
    super.errorCode = 'RATE_LIMITED',
    super.requestId,
    super.details,
    super.errorEnvelope,
    super.cause,
  });
}

/// Thrown on HTTP 500+ Internal Server Error or downstream failure.
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Terjadi kesalahan pada server',
    super.statusCode = 500,
    super.errorCode = 'INTERNAL_ERROR',
    super.requestId,
    super.details,
    super.errorEnvelope,
    super.cause,
  });
}
