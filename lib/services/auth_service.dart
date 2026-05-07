import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const bool useMockMode = true;

  // TODO: Pindahkan ke environment variables
  static const String _googleClientId =
      '756280521811-8g4mpvlputn04ltqdcghionnbrebhqbo.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _googleClientId,
    scopes: ['email', 'profile'],
  );

  final _storage = const FlutterSecureStorage();

  Future<String?> signInWithGoogle() async {
    if (useMockMode) {
      return mockSignInDev();
    }

    // 1. Lakukan sign in dengan Google
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) {
      // Pengguna membatalkan login
      return null;
    }

    // 2. Dapatkan Google ID Token
    final GoogleSignInAuthentication auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw Exception("Gagal mendapatkan Google ID Token");
    }

    // 3. Kirim token ke backend
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/v1/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': idToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Try several common places where the backend might place the JWT.
      String? jwtToken;
      if (data is Map<String, dynamic>) {
        jwtToken =
            data['data'] is Map
                ? (data['data']['token'] ??
                    data['data']['accessToken'] ??
                    data['data']['access_token'])
                : null;
        jwtToken ??=
            data['token'] ?? data['accessToken'] ?? data['access_token'];
      }

      if (jwtToken != null && jwtToken.isNotEmpty) {
        // 4. Simpan token JWT
        await _storage.write(key: 'jwt_token', value: jwtToken);
        return jwtToken;
      } else {
        // Provide the raw response body to help debugging backend changes.
        throw Exception(
          "Respons dari server tidak valid (token tidak ditemukan). Body: ${response.body}",
        );
      }
    } else {
      throw Exception("Login gagal: ${response.body}");
    }
  }

  Future<String> mockSignInDev() async {
    const token = 'mock-dev-token';
    await _storage.write(key: 'jwt_token', value: token);
    return token;
  }

  Future<void> logout() async {
    if (useMockMode) {
      await _storage.delete(key: 'jwt_token');
      return;
    }

    // Hapus token dari kedua tempat
    await _googleSignIn.signOut();
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() => _storage.read(key: 'jwt_token');
}
