import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:recova/core/config/app_config.dart';
import 'package:recova/core/network/api_client.dart';

/// Test client helper that delegates `send(request)` to a custom handler.
class FakeHttpClient extends http.BaseClient {
  FakeHttpClient(this.handler);

  final Future<http.Response> Function(http.BaseRequest request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

void main() {
  const testConfig = AppConfig(
    apiBaseUrl: 'https://api.recova.test/api/v1',
    environment: 'test',
  );

  group('ApiClient URL and Header Assembly', () {
    test('buildUri resolves relative paths with leading slash', () {
      final client = ApiClient(config: testConfig);
      final uri = client.buildUri('/routine/checkin');

      expect(
        uri.toString(),
        equals('https://api.recova.test/api/v1/routine/checkin'),
      );
    });

    test('buildUri resolves relative paths without leading slash', () {
      final client = ApiClient(config: testConfig);
      final uri = client.buildUri('routine/statistics');

      expect(
        uri.toString(),
        equals('https://api.recova.test/api/v1/routine/statistics'),
      );
    });

    test('buildUri preserves absolute HTTP and HTTPS URLs', () {
      final client = ApiClient(config: testConfig);
      final uri = client.buildUri('https://auth.recova.test/oauth/token');

      expect(uri.toString(), equals('https://auth.recova.test/oauth/token'));
    });

    test('buildUri serializes and merges query parameters cleanly', () {
      final client = ApiClient(config: testConfig);
      final uri = client.buildUri('/community', {
        'category': 'saran',
        'limit': 20,
        'enabled': true,
        'tags': ['recovery', 'streak'],
        'skipped': null,
      });

      expect(uri.queryParameters['category'], equals('saran'));
      expect(uri.queryParameters['limit'], equals('20'));
      expect(uri.queryParameters['enabled'], equals('true'));
      expect(uri.queryParametersAll['tags'], equals(['recovery', 'streak']));
      expect(uri.queryParameters.containsKey('skipped'), isFalse);
    });

    test(
      'buildHeaders attaches default headers and merges custom headers',
      () async {
        final client = ApiClient(config: testConfig);
        final headers = await client.buildHeaders({
          'X-Custom-Header': 'custom',
        });

        expect(headers['Content-Type'], equals('application/json'));
        expect(headers['Accept'], equals('application/json'));
        expect(headers['Connection'], equals('close'));
        expect(headers['X-Custom-Header'], equals('custom'));
        expect(headers.containsKey('Authorization'), isFalse);
      },
    );

    test(
      'buildHeaders attaches Bearer token when tokenProvider returns value',
      () async {
        final client = ApiClient(
          config: testConfig,
          tokenProvider: () async => 'jwt_secret_token_123',
        );
        final headers = await client.buildHeaders();

        expect(headers['Authorization'], equals('Bearer jwt_secret_token_123'));
      },
    );

    test(
      'buildHeaders does not overwrite explicit Authorization header',
      () async {
        final client = ApiClient(
          config: testConfig,
          tokenProvider: () async => 'jwt_secret_token_123',
        );
        final headers = await client.buildHeaders({
          'Authorization': 'Bearer custom_override_token',
        });

        expect(
          headers['Authorization'],
          equals('Bearer custom_override_token'),
        );
      },
    );
  });

  group('ApiClient HTTP Operations and Envelope Deserialization', () {
    test(
      'GET request executes and deserializes SuccessEnvelope payload',
      () async {
        final fakeClient = FakeHttpClient((request) async {
          expect(request.method, equals('GET'));
          expect(
            request.url.toString(),
            equals('https://api.recova.test/api/v1/routine/statistics'),
          );
          expect(
            request.headers['Authorization'],
            equals('Bearer valid_token'),
          );

          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Statistik berhasil dimuat',
              'data': {'current_streak': 7, 'longest_streak': 14},
              'meta': {
                'trace': {
                  'request_id': 'req_stats_200',
                  'timestamp': '2026-05-10T12:00:00Z',
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(
          client: fakeClient,
          config: testConfig,
          tokenProvider: () async => 'valid_token',
        );

        final envelope = await apiClient.get<Map<String, dynamic>>(
          '/routine/statistics',
        );

        expect(envelope.success, isTrue);
        expect(envelope.message, equals('Statistik berhasil dimuat'));
        expect(envelope.data['current_streak'], equals(7));
        expect(envelope.meta?.trace?.requestId, equals('req_stats_200'));
      },
    );

    test(
      'POST request sends JSON payload and maps custom DTO via fromJson',
      () async {
        final fakeClient = FakeHttpClient((request) async {
          expect(request.method, equals('POST'));
          expect(request.headers['Content-Type'], equals('application/json'));

          final body = (request as http.Request).body;
          final decoded = jsonDecode(body) as Map<String, dynamic>;
          expect(decoded['is_successful'], isTrue);

          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Check-in berhasil',
              'data': {'id': 'checkin_100', 'streak_count': 5},
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);

        final result = await apiClient.post<int>(
          '/routine/checkin',
          data: {'is_successful': true},
          fromJson:
              (raw) => (raw as Map<String, dynamic>)['streak_count'] as int,
        );

        expect(result.success, isTrue);
        expect(result.data, equals(5));
        expect(result.message, equals('Check-in berhasil'));
      },
    );

    test(
      'PUT, PATCH, and DELETE requests execute with correct HTTP verbs',
      () async {
        final calledMethods = <String>[];

        final fakeClient = FakeHttpClient((request) async {
          calledMethods.add(request.method);
          return http.Response(
            jsonEncode({
              'success': true,
              'message': '${request.method} success',
              'data': {'status': 'ok'},
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);

        await apiClient.put('/users/settings', data: {'theme': 'dark'});
        await apiClient.patch('/users/profile', data: {'nickname': 'hero'});
        await apiClient.delete('/community/post_123');

        expect(calledMethods, equals(['PUT', 'PATCH', 'DELETE']));
      },
    );

    test(
      'HTTP 204 or empty response returns SuccessEnvelope with null data',
      () async {
        final fakeClient = FakeHttpClient((request) async {
          return http.Response('', 204);
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);
        final envelope = await apiClient.delete<dynamic>('/community/post_1');

        expect(envelope.success, isTrue);
        expect(envelope.data, isNull);
      },
    );

    test(
      'response pagination metadata deserializes limit, total, and hasMore',
      () async {
        final fakeClient = FakeHttpClient((request) async {
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'OK',
              'data': [1, 2, 3],
              'meta': {
                'pagination': {'limit': 10, 'total': 100, 'has_more': true},
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);
        final envelope = await apiClient.get<List<dynamic>>('/community');

        expect(envelope.meta?.pagination?.limit, equals(10));
        expect(envelope.meta?.pagination?.total, equals(100));
        expect(envelope.meta?.pagination?.hasMore, isTrue);
      },
    );
  });

  group('ApiClient Structured ErrorEnvelope Mapping', () {
    test(
      'HTTP 401 maps to UnauthorizedException with error envelope details',
      () async {
        final fakeClient = FakeHttpClient((request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'message': 'Autentikasi dibutuhkan',
              'data': null,
              'error': {
                'code': 'UNAUTHENTICATED',
                'details': null,
                'request_id': 'req_401_test',
              },
            }),
            401,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);

        expect(
          () => apiClient.get('/users/me'),
          throwsA(
            isA<UnauthorizedException>()
                .having((e) => e.statusCode, 'statusCode', equals(401))
                .having(
                  (e) => e.errorCode,
                  'errorCode',
                  equals('UNAUTHENTICATED'),
                )
                .having((e) => e.requestId, 'requestId', equals('req_401_test'))
                .having(
                  (e) => e.message,
                  'message',
                  equals('Autentikasi dibutuhkan'),
                )
                .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue),
          ),
        );
      },
    );

    test('HTTP 403 maps to ForbiddenException', () async {
      final fakeClient = FakeHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Akses komunitas dibatasi',
            'data': null,
            'error': {
              'code': 'FORBIDDEN',
              'details': null,
              'request_id': 'req_403_test',
            },
          }),
          403,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);

      expect(
        () => apiClient.post('/community', data: {'content': 'hello'}),
        throwsA(
          isA<ForbiddenException>()
              .having((e) => e.statusCode, 'statusCode', equals(403))
              .having((e) => e.isForbidden, 'isForbidden', isTrue)
              .having((e) => e.errorCode, 'errorCode', equals('FORBIDDEN')),
        ),
      );
    });

    test('HTTP 404 maps to NotFoundException', () async {
      final fakeClient = FakeHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Postingan tidak ditemukan',
            'data': null,
            'error': {
              'code': 'NOT_FOUND',
              'details': null,
              'request_id': 'req_404_test',
            },
          }),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);

      expect(
        () => apiClient.get('/community/post_999'),
        throwsA(
          isA<NotFoundException>()
              .having((e) => e.statusCode, 'statusCode', equals(404))
              .having((e) => e.isNotFound, 'isNotFound', isTrue),
        ),
      );
    });

    test('HTTP 409 maps to ConflictException', () async {
      final fakeClient = FakeHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Email sudah terdaftar',
            'data': null,
            'error': {
              'code': 'CONFLICT',
              'details': null,
              'request_id': 'req_409_test',
            },
          }),
          409,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);

      expect(
        () =>
            apiClient.post('/auth/register', data: {'email': 'test@recova.id'}),
        throwsA(
          isA<ConflictException>()
              .having((e) => e.statusCode, 'statusCode', equals(409))
              .having((e) => e.isConflict, 'isConflict', isTrue),
        ),
      );
    });

    test(
      'HTTP 422 maps to ValidationException with parsed field error details',
      () async {
        final fakeClient = FakeHttpClient((request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'message': 'Konten postingan terlalu pendek',
              'data': null,
              'error': {
                'code': 'VALIDATION_ERROR',
                'details': [
                  {
                    'field': 'content',
                    'message': 'Konten postingan terlalu pendek',
                  },
                  {'field': 'category', 'message': 'Kategori tidak valid'},
                ],
                'request_id': 'req_422_test',
              },
            }),
            422,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);

        expect(
          () => apiClient.post('/community', data: {'content': 'a'}),
          throwsA(
            isA<ValidationException>()
                .having((e) => e.statusCode, 'statusCode', equals(422))
                .having((e) => e.isValidationError, 'isValidationError', isTrue)
                .having((e) => e.errors.length, 'errors count', equals(2))
                .having(
                  (e) => e.errors.first.field,
                  'first error field',
                  equals('content'),
                )
                .having(
                  (e) => e.errors.first.message,
                  'first error message',
                  equals('Konten postingan terlalu pendek'),
                ),
          ),
        );
      },
    );

    test('HTTP 429 maps to RateLimitedException', () async {
      final fakeClient = FakeHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Terlalu banyak permintaan',
            'data': null,
            'error': {
              'code': 'RATE_LIMITED',
              'details': null,
              'request_id': 'req_429_test',
            },
          }),
          429,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);

      expect(
        () => apiClient.post('/ai/ask-coach', data: {'message': 'help'}),
        throwsA(
          isA<RateLimitedException>()
              .having((e) => e.statusCode, 'statusCode', equals(429))
              .having((e) => e.isRateLimited, 'isRateLimited', isTrue),
        ),
      );
    });

    test('HTTP 500 maps to ServerException', () async {
      final fakeClient = FakeHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Terjadi kesalahan sistem internal',
            'data': null,
            'error': {
              'code': 'INTERNAL_ERROR',
              'details': null,
              'request_id': 'req_500_test',
            },
          }),
          500,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);

      expect(
        () => apiClient.get('/routine/statistics'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', equals(500))
              .having((e) => e.isServerError, 'isServerError', isTrue),
        ),
      );
    });

    test(
      'non-JSON 502 Bad Gateway response maps to ApiException with status code',
      () async {
        final fakeClient = FakeHttpClient((request) async {
          return http.Response('<html>502 Bad Gateway</html>', 502);
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);

        expect(
          () => apiClient.get('/routine/checkin'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', equals(502))
                .having((e) => e.isServerError, 'isServerError', isTrue),
          ),
        );
      },
    );

    test('HTTP 200 with success:false throws ApiException', () async {
      final fakeClient = FakeHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Operasi ditolak oleh server',
            'data': null,
            'error': {
              'code': 'OPERATION_REJECTED',
              'details': null,
              'request_id': 'req_200_false',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);

      expect(
        () => apiClient.get('/routine/statistics'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            equals('Operasi ditolak oleh server'),
          ),
        ),
      );
    });

    test(
      'HTTP 200 with malformed JSON throws ResponseParseException',
      () async {
        final fakeClient = FakeHttpClient((request) async {
          return http.Response('{not-a-valid-json', 200);
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);

        expect(
          () => apiClient.get('/routine/statistics'),
          throwsA(isA<ResponseParseException>()),
        );
      },
    );
  });

  group('ApiClient Transport Failures and Timeouts', () {
    test('SocketException maps to ConnectionNetworkException', () async {
      final fakeClient = FakeHttpClient((request) async {
        throw const SocketException('Network unreachable');
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);

      expect(
        () => apiClient.get('/routine/statistics'),
        throwsA(
          isA<ConnectionNetworkException>().having(
            (e) => e.message,
            'message',
            contains('Tidak ada koneksi internet'),
          ),
        ),
      );
    });

    test('TimeoutException maps to TimeoutNetworkException', () async {
      final fakeClient = FakeHttpClient((request) async {
        throw TimeoutException('Request timed out after 30s');
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);

      expect(
        () => apiClient.get('/routine/statistics'),
        throwsA(
          isA<TimeoutNetworkException>().having(
            (e) => e.message,
            'message',
            contains('Koneksi ke server terputus'),
          ),
        ),
      );
    });

    test('HandshakeException maps to ConnectionNetworkException', () async {
      final fakeClient = FakeHttpClient((request) async {
        throw const HandshakeException('Certificate validation failed');
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);

      expect(
        () => apiClient.get('/routine/statistics'),
        throwsA(
          isA<ConnectionNetworkException>().having(
            (e) => e.message,
            'message',
            contains('verifikasi keamanan TLS/SSL'),
          ),
        ),
      );
    });

    test(
      'HttpException (IOException) maps to ConnectionNetworkException',
      () async {
        final fakeClient = FakeHttpClient((request) async {
          throw const HttpException('Connection closed prematurely');
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);

        expect(
          () => apiClient.get('/routine/statistics'),
          throwsA(
            isA<ConnectionNetworkException>().having(
              (e) => e.message,
              'message',
              contains('Koneksi ke server terputus'),
            ),
          ),
        );
      },
    );

    test('SuccessEnvelope parses untyped Map meta defensively', () {
      final raw = <dynamic, dynamic>{
        'success': true,
        'message': 'OK',
        'data': {'id': 1},
        'meta': <dynamic, dynamic>{
          'pagination': <dynamic, dynamic>{'total': 50, 'limit': 10},
        },
      };

      final envelope = SuccessEnvelope<Map<dynamic, dynamic>>.fromJson(
        Map<String, dynamic>.from(raw),
      );

      expect(envelope.meta?.pagination?.total, equals(50));
      expect(envelope.meta?.pagination?.limit, equals(10));
    });
  });
}
