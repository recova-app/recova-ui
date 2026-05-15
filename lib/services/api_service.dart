import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:recova/services/auth_service.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/models/post_model.dart';
import 'package:recova/models/community_comment_model.dart';
import 'package:recova/models/education_model.dart';
import 'package:recova/models/daily_content_model.dart';
import 'package:recova/models/journal_model.dart';

class ApiService {
  // Ganti ini dengan URL backend kamu
  static const String baseUrl = 'https://recova.salmanabdurrahman.my.id/api/v1';
  static final AuthService _authService = AuthService();

  static String _normalizeCommunityCategory(String category) {
    final normalized = category.toLowerCase().trim();
    switch (normalized) {
      case 'nasihat':
      case 'advice':
      case 'saran':
        return 'saran';
      case 'bantuan':
      case 'help':
        return 'bantuan';
      case 'motivasi':
      case 'motivation':
        return 'motivasi';
      case 'cerita':
        return 'cerita';
      case 'pertanyaan':
        return 'pertanyaan';
      default:
        return normalized;
    }
  }

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
  }) async {
    http.Response? response;
    try {
      final payload = <String, dynamic>{
        'mood': mood,
        "is_successful": true,
        'commitment': commitment,
        'content': content,
      };

      response = await _request(
        'POST',
        Uri.parse('$baseUrl/routine/checkin'),
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

    static Future<CheckInResult> relapse({
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
  static Future<List<Post>> getCommunityPosts({String? category}) async {
    http.Response? response;
    try {
      final normalizedCategory = category == null || category.isEmpty
          ? null
          : _normalizeCommunityCategory(category);
      final uri = normalizedCategory == null || normalizedCategory.isEmpty
          ? Uri.parse('$baseUrl/community')
          : Uri.parse('$baseUrl/community?category=$normalizedCategory');
      response = await _request('GET', uri, timeoutSeconds: 15);
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
      final normalizedCategory = _normalizeCommunityCategory(category);
      response = await _request(
        'POST',
        Uri.parse('$baseUrl/community'),
        body: jsonEncode({
          'title': title,
          'content': content,
          'category': normalizedCategory, // Selalu kirim nilai kategori yang valid ke backend.
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

  static Future<List<CommunityComment>> getPostComments({
    required String postId,
    int limit = 100,
  }) async {
    http.Response? response;
    try {
      response = await _request(
        'GET',
        Uri.parse('$baseUrl/community/$postId/comments?limit=$limit'),
        timeoutSeconds: 15,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final thread = data['data'];
        final comments = thread is Map ? thread['comments'] : null;
        final list = comments is List ? comments : const [];
        return list
            .whereType<Map>()
            .map((e) => CommunityComment.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  static Future<void> addPostComment({
    required String postId,
    required String content,
  }) async {
    http.Response? response;
    try {
      response = await _request(
        'POST',
        Uri.parse('$baseUrl/community/$postId/comments'),
        body: jsonEncode({'content': content}),
        timeoutSeconds: 15,
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        await _check401(response);
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  static Future<void> addCommentReply({
    required String postId,
    required String commentId,
    required String content,
  }) async {
    http.Response? response;
    try {
      response = await _request(
        'POST',
        Uri.parse('$baseUrl/community/$postId/comments/$commentId/replies'),
        body: jsonEncode({'content': content}),
        timeoutSeconds: 15,
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        await _check401(response);
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
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

  // === AI COACH ===
  static Future<List<Map<String, dynamic>>> getAiChatHistory({int limit = 50}) async {
    http.Response? response;
    try {
      response = await _request(
        'GET',
        Uri.parse('$baseUrl/ai/chat-history?limit=$limit'),
        timeoutSeconds: 15,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = data['data'];
        if (raw is List) {
          return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        }
        return [];
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  static Future<Map<String, dynamic>> askAiCoach({required String message}) async {
    http.Response? response;
    try {
      response = await _request(
        'POST',
        Uri.parse('$baseUrl/ai/ask-coach'),
        body: jsonEncode({'message': message}),
        timeoutSeconds: 25,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final payload = data['data'];
        if (payload is Map) {
          return Map<String, dynamic>.from(payload);
        }
        return {};
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  static Future<String> getAiPersonaPreference() async {
    http.Response? response;
    try {
      response = await _request(
        'GET',
        Uri.parse('$baseUrl/ai/persona-preferences'),
        timeoutSeconds: 15,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final persona = data['data']?['persona'];
        if (persona is String && persona.isNotEmpty) {
          return persona;
        }
      } else {
        await _check401(response);
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
    return 'supportive';
  }

  static Future<void> updateAiPersonaPreference({required String persona}) async {
    http.Response? response;
    try {
      response = await _request(
        'PUT',
        Uri.parse('$baseUrl/ai/persona-preferences'),
        body: jsonEncode({'persona': persona}),
        timeoutSeconds: 15,
      );
      if (response.statusCode != 200) {
        await _check401(response);
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  // === RELAPSE STATISTICS ===
  static Future<RelapseStatisticsResponse> getRelapseStatistics() async {
    http.Response? response;
    try {
      response = await _request(
        'GET',
        Uri.parse('$baseUrl/routine/relapses/statistics'),
        timeoutSeconds: 15,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RelapseStatisticsResponse.fromJson(data['data'] ?? data);
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  // === JOURNALS ===
  static Future<List<Journal>> getJournals() async {
    http.Response? response;
    try {
      response = await _request('GET', Uri.parse('$baseUrl/journals'), timeoutSeconds: 15);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List? ?? [];
        return list.map((e) => Journal.fromJson(e)).toList();
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }

  static Future<Journal> createJournal({required String content}) async {
    http.Response? response;
    try {
      response = await _request(
        'POST',
        Uri.parse('$baseUrl/journals'),
        body: jsonEncode({'content': content}),
        timeoutSeconds: 15,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Journal.fromJson(data['data']);
      }
      await _check401(response);
      throw Exception(_handleError(null, response));
    } catch (e) {
      if (e is Exception && e.toString().contains('Sesi berakhir')) rethrow;
      throw Exception(_handleError(e, response));
    }
  }
}
