import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:recova/core/config/app_config.dart';
import 'package:recova/core/network/api_envelope.dart';
import 'package:recova/core/network/network_exceptions.dart';

export 'package:recova/core/network/api_envelope.dart';
export 'package:recova/core/network/network_exceptions.dart';

/// Injectable HTTP client encapsulating authentication, serialization,
/// timeout policies, and structured OpenAPI envelope exception mapping.
class ApiClient {
  ApiClient({http.Client? client, AppConfig? config, this.tokenProvider})
    : _client = client ?? _createDefaultClient(),
      _isInternalClient = client == null,
      config = config ?? AppConfig.current;

  final http.Client _client;
  final bool _isInternalClient;
  final AppConfig config;
  final Future<String?> Function()? tokenProvider;

  /// Default client with secure TLS verification and socket settings.
  static IOClient _createDefaultClient() {
    final inner =
        HttpClient()
          ..connectionTimeout = const Duration(seconds: 30)
          ..idleTimeout = const Duration(seconds: 0);
    return IOClient(inner);
  }

  /// Builds a fully-qualified [Uri] from a path and optional query parameters.
  Uri buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final Uri uri;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      uri = Uri.parse(path);
    } else {
      final base = config.v1BaseUrl;
      final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
      final normalizedBase = base.endsWith('/') ? base : '$base/';
      uri = Uri.parse('$normalizedBase$normalizedPath');
    }

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final cleanParams = <String, dynamic>{};
    queryParameters.forEach((key, value) {
      if (value != null) {
        if (value is Iterable) {
          cleanParams[key] = value.map((e) => e.toString()).toList();
        } else {
          cleanParams[key] = value.toString();
        }
      }
    });

    return uri.replace(
      queryParameters: {...uri.queryParameters, ...cleanParams},
    );
  }

  /// Prepares request headers attaching content-type, accept, and auth tokens.
  Future<Map<String, String>> buildHeaders([
    Map<String, String>? customHeaders,
  ]) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'close',
      ...?customHeaders,
    };

    final hasAuthHeader = headers.keys.any(
      (k) => k.toLowerCase() == 'authorization',
    );

    if (!hasAuthHeader && tokenProvider != null) {
      final token = await tokenProvider!();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Executes a GET request and maps the response into a [SuccessEnvelope].
  Future<SuccessEnvelope<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic rawData)? fromJson,
    Duration? timeout,
  }) => _send<T>(
    'GET',
    endpoint,
    headers: headers,
    queryParameters: queryParameters,
    fromJson: fromJson,
    timeout: timeout,
  );

  /// Executes a POST request and maps the response into a [SuccessEnvelope].
  Future<SuccessEnvelope<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic rawData)? fromJson,
    Duration? timeout,
  }) => _send<T>(
    'POST',
    endpoint,
    data: data,
    headers: headers,
    queryParameters: queryParameters,
    fromJson: fromJson,
    timeout: timeout,
  );

  /// Executes a PUT request and maps the response into a [SuccessEnvelope].
  Future<SuccessEnvelope<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic rawData)? fromJson,
    Duration? timeout,
  }) => _send<T>(
    'PUT',
    endpoint,
    data: data,
    headers: headers,
    queryParameters: queryParameters,
    fromJson: fromJson,
    timeout: timeout,
  );

  /// Executes a PATCH request and maps the response into a [SuccessEnvelope].
  Future<SuccessEnvelope<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic rawData)? fromJson,
    Duration? timeout,
  }) => _send<T>(
    'PATCH',
    endpoint,
    data: data,
    headers: headers,
    queryParameters: queryParameters,
    fromJson: fromJson,
    timeout: timeout,
  );

  /// Executes a DELETE request and maps the response into a [SuccessEnvelope].
  Future<SuccessEnvelope<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic rawData)? fromJson,
    Duration? timeout,
  }) => _send<T>(
    'DELETE',
    endpoint,
    data: data,
    headers: headers,
    queryParameters: queryParameters,
    fromJson: fromJson,
    timeout: timeout,
  );

  /// Closes the HTTP client if managed internally.
  void close() {
    if (_isInternalClient) {
      _client.close();
    }
  }

  Future<SuccessEnvelope<T>> _send<T>(
    String method,
    String endpoint, {
    dynamic data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic rawData)? fromJson,
    Duration? timeout,
  }) async {
    final uri = buildUri(endpoint, queryParameters);
    final effectiveHeaders = await buildHeaders(headers);
    final effectiveTimeout = timeout ?? config.receiveTimeout;

    String? bodyString;
    if (data != null) {
      if (data is String) {
        bodyString = data;
      } else {
        bodyString = jsonEncode(data);
      }
    }

    try {
      final request = http.Request(method.toUpperCase(), uri);
      if (bodyString != null) {
        request.body = bodyString;
      }
      request.headers.addAll(effectiveHeaders);

      final stopwatch = Stopwatch()..start();
      final streamed = await _client.send(request).timeout(effectiveTimeout);
      final elapsed = stopwatch.elapsed;
      final remainingTimeout =
          effectiveTimeout > elapsed
              ? effectiveTimeout - elapsed
              : Duration.zero;
      final response = await http.Response.fromStream(
        streamed,
      ).timeout(remainingTimeout);

      return _handleResponse<T>(response, fromJson);
    } on TimeoutException catch (e) {
      throw TimeoutNetworkException(cause: e);
    } on SocketException catch (e) {
      throw ConnectionNetworkException(cause: e);
    } on HandshakeException catch (e) {
      throw ConnectionNetworkException(
        message: 'Gagal melakukan verifikasi keamanan TLS/SSL.',
        cause: e,
      );
    } on IOException catch (e) {
      throw ConnectionNetworkException(
        message: 'Koneksi ke server terputus. Periksa jaringan Anda.',
        cause: e,
      );
    } on http.ClientException catch (e) {
      throw ConnectionNetworkException(
        message:
            e.message.isNotEmpty
                ? e.message
                : 'Tidak ada koneksi internet. Periksa jaringan Anda.',
        cause: e,
      );
    }
  }

  SuccessEnvelope<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic rawData)? fromJson,
  ) {
    final statusCode = response.statusCode;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    dynamic decodedBody;
    if (response.body.trim().isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } on FormatException catch (e) {
        if (isSuccess) {
          throw ResponseParseException(
            message: 'Gagal memproses format data respons.',
            rawBody: response.body,
            cause: e,
          );
        }
        throw ApiException.fromStatus(
          statusCode: statusCode,
          message: 'Permintaan gagal dengan status $statusCode',
          cause: response.body,
        );
      }
    }

    if (!isSuccess) {
      if (decodedBody is Map<String, dynamic>) {
        final envelope = ErrorEnvelope.fromJson(decodedBody);
        throw ApiException.fromStatus(
          statusCode: statusCode,
          errorEnvelope: envelope,
          cause: response.body,
        );
      } else if (decodedBody is Map) {
        final envelope = ErrorEnvelope.fromJson(
          Map<String, dynamic>.from(decodedBody),
        );
        throw ApiException.fromStatus(
          statusCode: statusCode,
          errorEnvelope: envelope,
          cause: response.body,
        );
      } else {
        throw ApiException.fromStatus(
          statusCode: statusCode,
          message: 'Permintaan gagal dengan status $statusCode',
          cause: response.body,
        );
      }
    }

    if (decodedBody == null) {
      final dynamic emptyData = null;
      return SuccessEnvelope<T>(
        success: true,
        message: '',
        data: emptyData as T,
      );
    }

    if (decodedBody is Map<String, dynamic>) {
      if (decodedBody['success'] == false) {
        final envelope = ErrorEnvelope.fromJson(decodedBody);
        throw ApiException.fromStatus(
          statusCode: statusCode,
          errorEnvelope: envelope,
          cause: response.body,
        );
      }
      return SuccessEnvelope<T>.fromJson(decodedBody, fromJson);
    } else if (decodedBody is Map) {
      final map = Map<String, dynamic>.from(decodedBody);
      if (map['success'] == false) {
        final envelope = ErrorEnvelope.fromJson(map);
        throw ApiException.fromStatus(
          statusCode: statusCode,
          errorEnvelope: envelope,
          cause: response.body,
        );
      }
      return SuccessEnvelope<T>.fromJson(map, fromJson);
    } else {
      final T data =
          fromJson != null ? fromJson(decodedBody) : (decodedBody as T);
      return SuccessEnvelope<T>(success: true, message: '', data: data);
    }
  }
}
