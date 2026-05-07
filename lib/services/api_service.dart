import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // Untuk SocketException
import 'dart:async'; // Untuk TimeoutException
import 'package:recova/services/auth_service.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/models/post_model.dart';
import 'package:recova/models/education_model.dart';

class ApiService {
  static const bool useMockData = true;

  // Ganti ini dengan URL backend kamu
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  static final AuthService _authService = AuthService();

  static User? _mockUser;
  static Statistics? _mockStatistics;
  static final List<Post> _mockPosts = [];
  static final List<EducationContent> _mockEducationContents = [
    EducationContent(
      id: 'edu-1',
      title: 'Mengenali Pemicu Relapse',
      description:
          'Pelajari pola yang sering memicu dorongan dan cara meredakannya.',
      url: 'https://example.com/education/pemicu-relapse',
      thumbnailUrl: 'https://picsum.photos/seed/recova-edu-1/640/360',
      category: 'Mindset',
    ),
    EducationContent(
      id: 'edu-2',
      title: 'Rutinitas Malam yang Lebih Aman',
      description: 'Bangun kebiasaan yang menurunkan risiko di jam rawan.',
      url: 'https://example.com/education/rutinitas-malam',
      thumbnailUrl: 'https://picsum.photos/seed/recova-edu-2/640/360',
      category: 'Habit',
    ),
    EducationContent(
      id: 'edu-3',
      title: 'Mengelola Dorongan dengan Teknik 5 Menit',
      description: 'Langkah singkat untuk menunda impuls dan kembali fokus.',
      url: 'https://example.com/education/teknik-5-menit',
      thumbnailUrl: 'https://picsum.photos/seed/recova-edu-3/640/360',
      category: 'Mindset',
    ),
  ];

  static User _getMockUser() {
    _mockUser ??= User(
      id: 'mock-user-1',
      email: 'recova.demo@example.com',
      nickname: 'Recova User',
      userWhy: 'Ingin hidup lebih sehat dan tenang',
      checkinTime: '10 pm',
      createdAt: DateTime(2026, 1, 8),
    );
    return _mockUser!;
  }

  static List<String> _buildMockStreakCalendar({
    required int days,
    required bool includeToday,
  }) {
    final now = DateTime.now();
    final endDate = includeToday ? now : now.subtract(const Duration(days: 1));
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

    return List.generate(days, (index) {
      final day = normalizedEnd.subtract(Duration(days: days - 1 - index));
      return DateTime(day.year, day.month, day.day).toIso8601String();
    });
  }

  static Statistics _getMockStatistics() {
    _mockStatistics ??= Statistics(
      currentStreak: 12,
      longestStreak: 18,
      totalCheckins: 20,
      streakCalendar: _buildMockStreakCalendar(days: 12, includeToday: false),
    );
    return _mockStatistics!;
  }

  static User get mockUser => _getMockUser();

  static Statistics get mockStatistics => _getMockStatistics();

  static void _seedMockPosts() {
    if (_mockPosts.isNotEmpty) return;

    final user = _getMockUser();
    _mockPosts.addAll([
      Post(
        id: 'post-1',
        title: 'Tetap jalan walau hari ini berat',
        content:
            'Hari yang sulit bukan berarti prosesmu gagal. Ambil napas, istirahat sebentar, lalu lanjut lagi pelan-pelan.',
        category: 'Motivasi',
        commentCount: 4,
        likeCount: 18,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        userId: 'user-2',
        username: 'Rafi',
        userStreak: 14,
      ),
      Post(
        id: 'post-2',
        title: 'Butuh bantuan saat malam hari',
        content:
            'Biasanya dorongan paling kuat datang pas malam. Ada yang punya rutinitas pengganti yang efektif?',
        category: 'Bantuan',
        commentCount: 7,
        likeCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        userId: 'user-3',
        username: 'Nanda',
        userStreak: 9,
      ),
      Post(
        id: 'post-3',
        title: 'Nasihat untuk yang baru mulai',
        content:
            'Jangan fokus ke kesempurnaan. Fokus ke hari ini, lalu ulangi besok. Progress kecil tetap progress.',
        category: 'Nasihat',
        commentCount: 3,
        likeCount: 22,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user-4',
        username: 'Dimas',
        userStreak: 21,
      ),
      Post(
        id: 'post-4',
        title: 'Jurnal malam membantu banget',
        content:
            'Menulis 3 hal yang bikin lega sebelum tidur ternyata cukup bantu mengurangi pikiran acak.',
        category: 'Motivasi',
        commentCount: 2,
        likeCount: 9,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'user-5',
        username: 'Alya',
        userStreak: 7,
      ),
    ]);

    _mockPosts.insert(
      0,
      Post(
        id: 'post-self',
        title: 'Hari ini kita fokus bertahan',
        content:
            'Aku masih jaga streak dan berusaha tetap konsisten walau dorongan datang. Satu langkah kecil cukup.',
        category: 'Nasihat',
        commentCount: 1,
        likeCount: 6,
        createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
        userId: user.id,
        username: user.nickname,
        userStreak: _getMockStatistics().currentStreak,
        isLiked: true,
      ),
    );
  }

  static Statistics _updateMockStatisticsAfterCheckIn() {
    final current = _getMockStatistics();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    if (current.streakCalendar.isNotEmpty &&
        current.streakCalendar.last.startsWith(today.substring(0, 10))) {
      return current;
    }

    final updatedCalendar = List<String>.from(current.streakCalendar)
      ..add(DateTime.now().toIso8601String());

    _mockStatistics = Statistics(
      currentStreak: current.currentStreak + 1,
      longestStreak:
          current.longestStreak > current.currentStreak + 1
              ? current.longestStreak
              : current.currentStreak + 1,
      totalCheckins: current.totalCheckins + 1,
      streakCalendar: updatedCalendar,
    );

    final user = _getMockUser();
    _mockUser = User(
      id: user.id,
      email: user.email,
      nickname: user.nickname,
      userWhy: user.userWhy,
      checkinTime: user.checkinTime,
      createdAt: user.createdAt,
    );

    return _mockStatistics!;
  }

  // === Header helper ===
  static Future<Map<String, String>> getHeaders() async {
    if (useMockData) {
      return {'Content-Type': 'application/json'};
    }

    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
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

  // === USER ===
  static Future<User> getUserMe() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 350));
      return _getMockUser();
    }

    http.Response? response;
    try {
      response = await http
          .get(Uri.parse('$baseUrl/users/me'), headers: await getHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['data'] ?? data);
      } else {
        // Jika otorisasi gagal, paksa logout agar aplikasi tidak tetap berada di state login dengan token tidak valid
        if (response.statusCode == 401 || response.statusCode == 403) {
          await _authService.logout();
          throw Exception('Sesi berakhir. Silakan login kembali.');
        }
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      throw Exception(_handleError(e, response));
    }
  }

  // === STATISTICS ===
  static Future<Statistics> getStatistics() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 350));
      return _getMockStatistics();
    }

    http.Response? response;
    try {
      response = await http
          .get(
            Uri.parse('$baseUrl/routine/statistics'),
            headers: await getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Statistics.fromJson(data['data'] ?? data);
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          await _authService.logout();
          throw Exception('Sesi berakhir. Silakan login kembali.');
        }
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      throw Exception(_handleError(e, response));
    }
  }

  // === ROUTINE / CHECK-IN ===
  static Future<CheckInResult> checkIn({required String journal}) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));

      if (journal.trim().isEmpty) {
        throw Exception('Isi jurnal terlebih dahulu');
      }

      final updatedStats = _updateMockStatisticsAfterCheckIn();
      final result = CheckInResult(
        id: 'checkin-${DateTime.now().millisecondsSinceEpoch}',
        startDate: DateTime.now().subtract(
          Duration(
            days:
                updatedStats.currentStreak > 0
                    ? updatedStats.currentStreak - 1
                    : 0,
          ),
        ),
        endDate: null,
        isActive: true,
      );
      return result;
    }

    http.Response? response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/routine/checkin'), // Sesuai dokumentasi backend
            headers: await getHeaders(),
            body: jsonEncode({
              'content': journal, // Menggunakan 'content' sesuai dokumentasi
              'isSuccessful':
                  true, // Menggunakan 'isSuccessful' sesuai dokumentasi
              'mood': 'Normal', // Menggunakan 'mood' sesuai dokumentasi
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CheckInResult.fromJson(data['data']);
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          await _authService.logout();
          throw Exception('Sesi berakhir. Silakan login kembali.');
        }
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      throw Exception(_handleError(e, response));
    }
  }

  // === COMMUNITY ===
  static Future<List<Post>> getCommunityPosts() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      _seedMockPosts();
      return List<Post>.from(_mockPosts);
    }

    http.Response? response;
    try {
      response = await http
          .get(Uri.parse('$baseUrl/community'), headers: await getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        return list.map((e) => Post.fromJson(e)).toList();
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          await _authService.logout();
          throw Exception('Sesi berakhir. Silakan login kembali.');
        }
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      throw Exception(_handleError(e, response));
    }
  }

  static Future<Post> createPost({
    required String title,
    required String content,
    required String category,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 450));
      _seedMockPosts();

      final user = _getMockUser();
      final currentStats = _getMockStatistics();
      final post = Post(
        id: 'post-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        content: content,
        category: category,
        commentCount: 0,
        likeCount: 0,
        createdAt: DateTime.now(),
        userId: user.id,
        username: user.nickname,
        userStreak: currentStats.currentStreak,
      );
      _mockPosts.insert(0, post);
      return post;
    }

    http.Response? response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/community'),
            headers: await getHeaders(),
            body: jsonEncode({
              'title': title,
              'content': content,
              'category': category, // Mengirim kategori ke backend
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        // 201 Created
        final data = jsonDecode(response.body);
        return Post.fromJson(data['data']);
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          await _authService.logout();
          throw Exception('Sesi berakhir. Silakan login kembali.');
        }
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      throw Exception(_handleError(e, response));
    }
  }

  static Future<void> likePost(String postId) async {
    if (useMockData) {
      final index = _mockPosts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _mockPosts[index];
        _mockPosts[index] = post.copyWith(
          isLiked: true,
          likeCount: post.likeCount + 1,
        );
      }
      return;
    }

    http.Response? response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/community/$postId/like'),
            headers: await getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      throw Exception(_handleError(e, response));
    }
  }

  static Future<void> unlikePost(String postId) async {
    if (useMockData) {
      final index = _mockPosts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _mockPosts[index];
        _mockPosts[index] = post.copyWith(
          isLiked: false,
          likeCount: post.likeCount > 0 ? post.likeCount - 1 : 0,
        );
      }
      return;
    }

    http.Response? response;
    try {
      // Umumnya, unlike menggunakan metode DELETE
      response = await http
          .delete(
            Uri.parse('$baseUrl/community/$postId/like'),
            headers: await getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      throw Exception(_handleError(e, response));
    }
  }

  // === EDUCATION ===
  static Future<List<EducationContent>> getEducationContents() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return List<EducationContent>.from(_mockEducationContents);
    }

    http.Response? response;
    try {
      response = await http
          .get(Uri.parse('$baseUrl/education'), headers: await getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        return list.map((e) => EducationContent.fromJson(e)).toList();
      } else {
        if (response.statusCode == 401 || response.statusCode == 403) {
          await _authService.logout();
          throw Exception('Sesi berakhir. Silakan login kembali.');
        }
        throw Exception(_handleError(null, response));
      }
    } catch (e) {
      throw Exception(_handleError(e, response));
    }
  }
}
