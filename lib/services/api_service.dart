import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:recova/services/auth_service.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/models/post_model.dart';
import 'package:recova/models/education_model.dart';
import 'package:recova/models/daily_content_model.dart';

class ApiService {
  // Ganti ini dengan URL backend kamu
  static const String baseUrl = 'https://recova.salmanabdurrahman.my.id/api/v1';
  static final AuthService _authService = AuthService();

  /// Returns a fresh [IOClient] that accepts the server's SSL certificate.
  static IOClient _buildClient() {
    final inner = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 0)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(inner);
  }

  // === Header helper ===
  static Future<Map<String, String>> getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Connection': 'close',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // === Helper untuk parsing error ===
  static String _handleError(dynamic e, http.Response? response) {
    if (e is SocketException) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    }
    if (e is TimeoutException) {
      return 'Koneksi ke server terputus. Silakan coba lagi.';
    }
    if (response != null) {
      try {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? 'Terjadi error: ${response.statusCode}';
      } catch (_) {
        return 'Gagal memproses respons dari server. Kode: ${response.statusCode}';
      }
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  // ── Centralized request helper with retry on HandshakeException ──────────

  /// Executes an HTTP request with automatic retries on transient TLS /
  /// socket errors (HandshakeException, SocketException, connection reset).
  ///
  /// [method] – 'GET', 'POST', 'DELETE', etc.
  /// [uri]    – full URI to hit.
  /// [body]   – optional JSON-encoded body for POST/PUT/PATCH.
  /// [timeoutSeconds] – per-attempt timeout.
  /// [maxRetries] – total number of attempts.
  static Future<http.Response> _request(
    String method,
    Uri uri, {
    String? body,
    int timeoutSeconds = 15,
    int maxRetries = 5,
  }) async {
    final headers = await getHeaders();
    Object? lastError;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      if (attempt > 0) {
        // Exponential back-off: 1s, 2s, 3s, 4s …
        await Future<void>.delayed(Duration(milliseconds: 1000 * attempt));
      }
      final client = _buildClient();
      try {
        late http.Response response;
        switch (method.toUpperCase()) {
          case 'GET':
            response = await client
                .get(uri, headers: headers)
                .timeout(Duration(seconds: timeoutSeconds));
            break;
          case 'POST':
            response = await client
                .post(uri, headers: headers, body: body)
                .timeout(Duration(seconds: timeoutSeconds));
            break;
          case 'DELETE':
            response = await client
                .delete(uri, headers: headers)
                .timeout(Duration(seconds: timeoutSeconds));
            break;
          case 'PUT':
            response = await client
                .put(uri, headers: headers, body: body)
                .timeout(Duration(seconds: timeoutSeconds));
            break;
          case 'PATCH':
            response = await client
                .patch(uri, headers: headers, body: body)
                .timeout(Duration(seconds: timeoutSeconds));
            break;
          default:
            throw UnsupportedError('HTTP method $method is not supported');
        }
        return response;
      } on HandshakeException catch (e) {
        print('[ApiService] HandshakeException on attempt ${attempt + 1}: $e');
        lastError = e;
      } on SocketException catch (e) {
        print('[ApiService] SocketException on attempt ${attempt + 1}: $e');
        lastError = e;
      } on http.ClientException catch (e) {
        final msg = e.message.toLowerCase();
        if (msg.contains('connection reset') ||
            msg.contains('connection closed') ||
            msg.contains('connection terminated')) {
          print('[ApiService] ClientException on attempt ${attempt + 1}: $e');
          lastError = e;
        } else {
          rethrow;
        }
      } on TimeoutException catch (e) {
        print('[ApiService] Timeout on attempt ${attempt + 1}: $e');
        lastError = e;
      } finally {
        client.close();
      }
    }
    throw Exception(
      'Gagal terhubung ke server setelah $maxRetries percobaan. '
      'Periksa koneksi internet kamu. (${lastError})',
    );
  }

  // === Handle 401/403 ===
  static Future<void> _check401(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _authService.logout();
      throw Exception('Sesi berakhir. Silakan login kembali.');
    }
  }

  // === USER ===
  static Future<User> getUserMe() async {
    http.Response? response;
    try {
      response = await _request('GET', Uri.parse('$baseUrl/users/me'), timeoutSeconds: 10);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['data'] ?? data);
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  // === STATISTICS ===
  static Future<Statistics> getStatistics() async {
    http.Response? response;
    try {
      response = await _request('GET', Uri.parse('$baseUrl/routine/statistics'), timeoutSeconds: 10);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Statistics.fromJson(data['data'] ?? data);
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  // === ROUTINE / CHECK-IN ===
  static Future<CheckInResult> checkIn({
    required String content,
    String mood = '',
    bool isSuccessful = true,
    String commitment = '',
    List<String>? relapseTrigger,
  }) async {
    http.Response? response;
    try {
      final payload = <String, dynamic>{
        'mood': mood,
        'commitment': commitment,
        'content': content,
      };
      if (relapseTrigger != null && relapseTrigger.isNotEmpty) {
        payload['relapse_trigger'] = relapseTrigger;
      }
      response = await _request(
        'POST',
        Uri.parse('$baseUrl/routine/relapses'),
        body: jsonEncode(payload),
        timeoutSeconds: 15,
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CheckInResult.fromJson(data['data']);
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  // === COMMUNITY ===
  static Future<List<Post>> getCommunityPosts() async {
    http.Response? response;
    try {
      response = await _request('GET', Uri.parse('$baseUrl/community'), timeoutSeconds: 15);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        return list.map((e) => Post.fromJson(e)).toList();
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  static Future<Post> createPost({required String title, required String content, required String category}) async {
    http.Response? response;
    try {
      response = await _request(
        'POST',
        Uri.parse('$baseUrl/community'),
        body: jsonEncode({
          'title': title,
          'content': content,
          'category': category, // Mengirim kategori ke backend
        }),
        timeoutSeconds: 15,
      );
      if (response.statusCode == 201) { // 201 Created
        final data = jsonDecode(response.body);
        return Post.fromJson(data['data']);
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  static Future<void> likePost(String postId) async {
    http.Response? response;
    try {
      response = await _request('POST', Uri.parse('$baseUrl/community/$postId/like'), timeoutSeconds: 10);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      throw Exception(_handleError(e, response));
    }
  }

  static Future<void> unlikePost(String postId) async {
    http.Response? response;
    try {
      // Umumnya, unlike menggunakan metode DELETE
      response = await _request('DELETE', Uri.parse('$baseUrl/community/$postId/like'), timeoutSeconds: 10);
      if (response.statusCode != 200) {
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      throw Exception(_handleError(e, response));
    }
  }


  // === EDUCATION ===
  static Future<List<EducationContent>> getEducationContents() async {
    http.Response? response;
    try {
      response = await _request('GET', Uri.parse('$baseUrl/education'), timeoutSeconds: 15);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        final list = data['data'] as List;
        return list.map((e) => EducationContent.fromJson(e)).toList();
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  // === USER SETTINGS ===
  static Future<User> updateUserSettings({
    String? nickname,
    String? recoveryReason,
    String? dailyCheckinTime,
    int? pornFreeGoal,
  }) async {
    http.Response? response;
    try {
      final payload = <String, dynamic>{};
      if (nickname != null) payload['nickname'] = nickname;
      if (recoveryReason != null) payload['recovery_reason'] = recoveryReason;
      if (dailyCheckinTime != null) payload['daily_checkin_time'] = dailyCheckinTime;
      if (pornFreeGoal != null) payload['porn_free_goal'] = pornFreeGoal;

      response = await _request(
        'PUT',
        Uri.parse('$baseUrl/users/settings'),
        body: jsonEncode(payload),
        timeoutSeconds: 15,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['data'] ?? data);
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  // === DAILY CONTENT ===
  static Future<DailyContent> getDailyContent() async {
    http.Response? response;
    try {
      response = await _request('GET', Uri.parse('$baseUrl/content/daily'), timeoutSeconds: 10);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DailyContent.fromJson(data['data'] ?? data);
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }
}
