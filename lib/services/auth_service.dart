import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:recova/services/onboarding_state.dart';
import 'dart:developer' as developer;

class AuthService {
  static const String _baseUrl = 'https://recova.salmanabdurrahman.my.id';
  static const String _webClientId =
      '756280521811-8g4mpvlputn04ltqdcghionnbrebhqbo.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  final _storage = const FlutterSecureStorage();

  // ── HTTP client factory ───────────────────────────────────────────────────

  /// Returns a fresh [IOClient] for every call.
  ///
  /// Key settings:
  /// - `persistentConnection = false` → sends `Connection: close`, so each
  ///   request uses its own TCP socket.  This prevents the
  ///   "Connection reset by peer (errno=104)" crash that occurs when Dart tries
  ///   to reuse a keep-alive connection that nginx has already closed.
  /// - `connectionTimeout = 30 s` → avoids hanging indefinitely.
  IOClient _buildClient() {
    final inner = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 0)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(inner);
  }

  /// POST helper with up to [maxRetries] automatic retries on transient
  /// socket / connection-reset errors.
  Future<http.Response> _post(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
    int maxRetries = 5,
  }) async {
    Object? lastError;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(milliseconds: 1000 * attempt));
      }
      final client = _buildClient();
      try {
        // 'Connection: close' tells the server (and Dart's socket layer) to
        // close the TCP connection after this response instead of keeping it
        // alive.  This prevents the "Connection reset by peer (errno=104)"
        // crash that occurs when Dart tries to reuse an already-closed socket.
        final mergedHeaders = {'Connection': 'close', ...headers};
        return await client
            .post(uri, headers: mergedHeaders, body: body)
            .timeout(const Duration(seconds: 30));
      } on SocketException catch (e) {
        lastError = e;
      } on HandshakeException catch (e) {
        // SSL/TLS handshake failure – retry
        lastError = e;
      } on http.ClientException catch (e) {
        print(e);
        // Retry only on connection-reset; surface everything else immediately.
        if (!e.message.toLowerCase().contains('connection reset') &&
            !e.message.toLowerCase().contains('connection closed')) {
          rethrow;
        }
        lastError = e;
      } finally {
        client.close();
      }
    }
    throw Exception(
      'Gagal terhubung ke server setelah $maxRetries percobaan. '
      'Periksa koneksi internet kamu.',
    );
  }

  // ── Auth data persistence ─────────────────────────────────────────────────

  /// Extract access token + onboarding flag from a successful auth response
  /// body, persist them, and return the inner `data` map.
  Future<Map<String, dynamic>> _persistAuthData(
      Map<String, dynamic> responseBody) async {
    final data = responseBody['data'] as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;

    final accessToken = session['access_token'] as String;
    await _storage.write(key: 'jwt_token', value: accessToken);

    final onboardingCompleted = user['onboarding_completed'] as bool? ?? false;
    await _storage.write(
      key: 'onboarding_completed',
      value: onboardingCompleted ? 'true' : 'false',
    );

    // Persist nickname from the auth response into OnboardingState
    final nickname = user['nickname'] as String? ?? '';
    if (nickname.isNotEmpty) {
      OnboardingState().nickname = nickname;
    }

    return data;
  }

  // ── Auth methods ──────────────────────────────────────────────────────────

  /// Sign in with Google OAuth.
  /// Returns the `data` map on success, or `null` if the user cancelled.
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) return null;

    final GoogleSignInAuthentication auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw Exception('Gagal mendapatkan Google ID Token');

    final response = await _post(
      Uri.parse('$_baseUrl/api/v1/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': idToken}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return await _persistAuthData(body);
    }
    throw Exception(body['message'] ?? 'Login Google gagal');
  }

  /// Log in with email or username + password.
  Future<Map<String, dynamic>> loginWithEmail({
    required String identifier,
    required String password,
  }) async {
    final response = await _post(
      Uri.parse('$_baseUrl/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return await _persistAuthData(body);
    }
    throw Exception(body['message'] ?? 'Login gagal');
  }

  /// Register a new manual account.
  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _post(
      Uri.parse('$_baseUrl/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201) {
      return await _persistAuthData(body);
    }
    throw Exception(body['message'] ?? 'Registrasi gagal');
  }

  // ── Session helpers ───────────────────────────────────────────────────────

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'onboarding_completed');
  }

  Future<bool> isOnboardingCompleted() async {
    final value = await _storage.read(key: 'onboarding_completed');
    return value == 'true';
  }

  Future<void> setOnboardingCompleted() async {
    await _storage.write(key: 'onboarding_completed', value: 'true');
  }

  Future<String?> getToken() => _storage.read(key: 'jwt_token');

  /// Submit onboarding data.
  Future<Map<String, dynamic>> submitOnboarding(Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) throw Exception('Sesi telah berakhir, silakan login kembali.');

    final response = await _post(
      Uri.parse('$_baseUrl/api/v1/auth/onboarding'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    developer.log(response.body, name: 'NetworkResponse');
    print(response.body);
     print(response.statusCode);
    print(response.headers);
    print(response.request);
    print(response.reasonPhrase);
    print(response.isRedirect);
    print(response.persistentConnection);
   
    if (response.statusCode == 200 || response.statusCode == 201) {
      await setOnboardingCompleted();
      return body['data'] as Map<String, dynamic>;
    }
    throw Exception(body['message'] ?? 'Gagal menyimpan data onboarding');
  }
}
