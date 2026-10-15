import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:recova/core/config/app_config.dart';
import 'package:recova/core/network/api_client.dart';
import 'package:recova/features/routine/data/datasources/routine_remote_data_source.dart';
import 'package:recova/features/routine/data/repositories/routine_repository_impl.dart';
import 'package:recova/features/routine/domain/repositories/routine_repository.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:recova/models/statistics_model.dart';

class MockRoutineRemoteDataSource extends Mock
    implements RoutineRemoteDataSource {}

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

  group('RoutineRemoteDataSourceImpl', () {
    test(
      'checkIn sends POST /routine/checkin with is_successful: true',
      () async {
        late http.BaseRequest capturedRequest;
        final fakeClient = FakeHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Check-in berhasil',
              'data': {
                'check_in': {
                  'id': 'checkin_123',
                  'user_id': 'user_123',
                  'check_in_date': '2026-05-10',
                  'check_in_day_name': 'Sabtu',
                  'mood': 'tenang',
                  'is_successful': true,
                  'commitment': 'Tetap konsisten',
                  'relapse_trigger': [],
                  'created_at': '2026-05-10T09:00:00Z',
                },
                'statistics': {
                  'current_streak': 5,
                  'longest_streak': 12,
                  'total_checkins': 24,
                  'total_attempts': 28,
                  'success_rate': 0.86,
                  'streak_calendar': ['2026-05-08', '2026-05-09', '2026-05-10'],
                  'relapse_calendar': ['2026-05-06'],
                  'relapse_count': 1,
                  'relapse_rate': 0.04,
                  'recovery_success_rate': 0.96,
                  'checkin_consistency_score': 90.0,
                },
                'relapse_solution': null,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);
        final dataSource = RoutineRemoteDataSourceImpl(apiClient: apiClient);

        final result = await dataSource.checkIn(
          content: 'Hari ini lancar dan terkendali',
          mood: 'tenang',
          commitment: 'Tetap konsisten',
        );

        expect(capturedRequest.method, equals('POST'));
        expect(capturedRequest.url.path, equals('/api/v1/routine/checkin'));
        expect(result.checkIn.id, equals('checkin_123'));
        expect(result.checkIn.isSuccessful, isTrue);
        expect(result.checkIn.mood, equals('tenang'));
        expect(result.statistics.currentStreak, equals(5));
        expect(result.relapseSolution, isNull);
      },
    );

    test(
      'getStatistics sends GET /routine/statistics and parses statistics',
      () async {
        late http.BaseRequest capturedRequest;
        final fakeClient = FakeHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Statistik berhasil diambil',
              'data': {
                'current_streak': 8,
                'longest_streak': 15,
                'total_checkins': 30,
                'total_attempts': 32,
                'success_rate': 0.94,
                'streak_calendar': ['2026-05-09', '2026-05-10'],
                'relapse_calendar': ['2026-05-01'],
                'relapse_count': 1,
                'relapse_rate': 0.03,
                'recovery_success_rate': 0.97,
                'checkin_consistency_score': 92.5,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);
        final dataSource = RoutineRemoteDataSourceImpl(apiClient: apiClient);

        final stats = await dataSource.getStatistics();

        expect(capturedRequest.method, equals('GET'));
        expect(capturedRequest.url.path, equals('/api/v1/routine/statistics'));
        expect(stats.currentStreak, equals(8));
        expect(stats.longestStreak, equals(15));
        expect(stats.totalCheckins, equals(30));
      },
    );

    test(
      'submitRelapse sends POST /routine/relapses and parses response',
      () async {
        late http.BaseRequest capturedRequest;
        final fakeClient = FakeHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Relapse berhasil dicatat',
              'data': {
                'relapse': {
                  'id': 'relapse_999',
                  'user_id': 'user_123',
                  'relapse_date': '2026-05-10',
                  'relapse_day_name': 'Sabtu',
                  'mood': 'cemas',
                  'commitment': 'Mulai lagi hari ini',
                  'relapse_trigger': ['stres kerja', 'kelelahan'],
                  'created_at': '2026-05-10T20:00:00Z',
                },
                'statistics': {
                  'current_streak': 0,
                  'longest_streak': 12,
                  'total_checkins': 23,
                  'total_attempts': 28,
                  'success_rate': 0.82,
                  'streak_calendar': ['2026-05-08'],
                  'relapse_calendar': ['2026-05-10'],
                  'relapse_count': 4,
                  'relapse_rate': 0.14,
                  'recovery_success_rate': 0.82,
                  'checkin_consistency_score': 84.5,
                },
                'relapse_solution': {
                  'title': 'Langkah Cepat',
                  'analysis': 'Trigger utama adalah stres kerja.',
                  'summary': 'Jauhkan gawai dan lakukan peregangan.',
                  'generated_at': '2026-05-10T20:05:00Z',
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);
        final dataSource = RoutineRemoteDataSourceImpl(apiClient: apiClient);

        final result = await dataSource.submitRelapse(
          mood: 'cemas',
          relapseTriggers: ['stres kerja', 'kelelahan'],
          commitment: 'Mulai lagi hari ini',
          content: 'Catatan relapse malam ini',
        );

        expect(capturedRequest.method, equals('POST'));
        expect(capturedRequest.url.path, equals('/api/v1/routine/relapses'));
        expect(result.relapse.id, equals('relapse_999'));
        expect(result.relapse.relapseTrigger, contains('stres kerja'));
        expect(result.statistics.currentStreak, equals(0));
        expect(result.relapseSolution?.title, equals('Langkah Cepat'));
      },
    );

    test(
      'getRelapseStatistics sends GET /routine/relapses/statistics',
      () async {
        late http.BaseRequest capturedRequest;
        final fakeClient = FakeHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Statistik relapse berhasil diambil',
              'data': {
                'statistics': {
                  'current_streak': 0,
                  'longest_streak': 12,
                  'total_checkins': 23,
                  'total_attempts': 28,
                  'success_rate': 0.82,
                  'streak_calendar': ['2026-05-08'],
                  'relapse_calendar': ['2026-05-10'],
                  'relapse_count': 4,
                  'relapse_rate': 0.14,
                  'recovery_success_rate': 0.82,
                  'checkin_consistency_score': 84.5,
                },
                'relapses': [],
                'hourly_relapse_distribution': [
                  {'hour_utc': 21, 'relapse_count': 3},
                ],
                'relapse_triggers_distribution': [
                  {
                    'relapse_trigger': 'stres kerja',
                    'relapse_trigger_count': 4,
                  },
                ],
                'peak_relapse_hours_utc': [21],
                'peak_relapse_count': 3,
                'ai_summary': 'Pola malam terdeteksi.',
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: fakeClient, config: testConfig);
        final dataSource = RoutineRemoteDataSourceImpl(apiClient: apiClient);

        final relapseStats = await dataSource.getRelapseStatistics();

        expect(capturedRequest.method, equals('GET'));
        expect(
          capturedRequest.url.path,
          equals('/api/v1/routine/relapses/statistics'),
        );
        expect(relapseStats.peakRelapseHoursUtc, equals([21]));
        expect(relapseStats.aiSummary, equals('Pola malam terdeteksi.'));
      },
    );

    test('getRelapseSolution sends POST /ai/relapse-solution', () async {
      late http.BaseRequest capturedRequest;
      final fakeClient = FakeHttpClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Solusi relapse berhasil dibuat',
            'data': {
              'title': 'Pulihkan Fokus Sekarang',
              'analysis': 'Pemicu utama muncul saat stres kerja.',
              'summary': 'Tarik nafas dalam dan hubungi teman akuntabilitas.',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);
      final dataSource = RoutineRemoteDataSourceImpl(apiClient: apiClient);

      final solution = await dataSource.getRelapseSolution(
        mood: 'cemas',
        relapseTriggers: ['stres kerja'],
        commitment: 'Saya ingin pulih',
      );

      expect(capturedRequest.method, equals('POST'));
      expect(capturedRequest.url.path, equals('/api/v1/ai/relapse-solution'));
      expect(solution.title, equals('Pulihkan Fokus Sekarang'));
      expect(
        solution.summary,
        equals('Tarik nafas dalam dan hubungi teman akuntabilitas.'),
      );
    });
  });

  group('RoutineRepositoryImpl', () {
    late MockRoutineRemoteDataSource mockRemoteDataSource;
    late RoutineRepository repository;

    setUp(() {
      mockRemoteDataSource = MockRoutineRemoteDataSource();
      repository = RoutineRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    test(
      'checkIn maps RoutineCheckInResponseData into CheckInResult correctly',
      () async {
        final mockResponse = RoutineCheckInResponseData(
          checkIn: RoutineCheckInData(
            id: 'checkin_456',
            userId: 'user_1',
            checkInDate: '2026-05-10',
            checkInDayName: 'Sabtu',
            mood: 'semangat',
            isSuccessful: true,
            commitment: 'Tetap maju',
            createdAt: DateTime.parse('2026-05-10T08:00:00Z'),
          ),
          statistics: Statistics(
            currentStreak: 3,
            longestStreak: 5,
            totalCheckins: 10,
            streakCalendar: const ['2026-05-08', '2026-05-09', '2026-05-10'],
          ),
          relapseSolution: null,
        );

        when(
          () => mockRemoteDataSource.checkIn(
            content: any(named: 'content'),
            mood: any(named: 'mood'),
            commitment: any(named: 'commitment'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await repository.checkIn(
          content: 'Check-in harian sukses',
          mood: 'semangat',
        );

        expect(result.id, equals('checkin_456'));
        expect(result.isActive, isTrue);
        expect(result.checkIn?.mood, equals('semangat'));
        expect(result.statistics?.currentStreak, equals(3));
        verify(
          () => mockRemoteDataSource.checkIn(
            content: 'Check-in harian sukses',
            mood: 'semangat',
            commitment: '',
          ),
        ).called(1);
      },
    );

    test(
      'submitRelapse maps RoutineRelapseResponseData into CheckInResult with isActive false',
      () async {
        final mockResponse = RoutineRelapseResponseData(
          relapse: RoutineRelapseData(
            id: 'relapse_789',
            userId: 'user_1',
            relapseDate: '2026-05-10',
            relapseDayName: 'Sabtu',
            mood: 'sedih',
            commitment: 'Bangkit kembali',
            relapseTrigger: const ['kesepian'],
            createdAt: DateTime.parse('2026-05-10T22:00:00Z'),
          ),
          statistics: Statistics(
            currentStreak: 0,
            longestStreak: 5,
            totalCheckins: 10,
            streakCalendar: const [],
          ),
          relapseSolution: RoutineRelapseSolutionData(
            title: 'Bangkit Kembali',
            analysis: 'Kesepian memicu dorongan.',
            summary: 'Luangkan waktu untuk relaksasi.',
          ),
        );

        when(
          () => mockRemoteDataSource.submitRelapse(
            mood: any(named: 'mood'),
            relapseTriggers: any(named: 'relapseTriggers'),
            commitment: any(named: 'commitment'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await repository.submitRelapse(
          mood: 'sedih',
          relapseTriggers: ['kesepian'],
          commitment: 'Bangkit kembali',
        );

        expect(result.id, equals('relapse_789'));
        expect(result.isActive, isFalse);
        expect(result.relapse?.relapseTrigger, equals(['kesepian']));
        expect(result.relapseSolution?.title, equals('Bangkit Kembali'));
      },
    );

    test('getStatistics delegates to remote data source', () async {
      final mockStats = Statistics(
        currentStreak: 4,
        longestStreak: 10,
        totalCheckins: 15,
        streakCalendar: const ['2026-05-10'],
      );

      when(
        () => mockRemoteDataSource.getStatistics(),
      ).thenAnswer((_) async => mockStats);

      final stats = await repository.getStatistics();
      expect(stats.currentStreak, equals(4));
      verify(() => mockRemoteDataSource.getStatistics()).called(1);
    });

    test('getRelapseStatistics delegates to remote data source', () async {
      final mockRelapseStats = RelapseStatisticsResponse(
        statistics: RelapseStats(
          currentStreak: 0,
          longestStreak: 10,
          totalCheckins: 12,
          totalAttempts: 15,
          successRate: 0.8,
          streakCalendar: const [],
          relapseCalendar: const ['2026-05-10'],
          relapseCount: 3,
          relapseRate: 0.2,
          recoverySuccessRate: 0.8,
          checkinConsistencyScore: 80.0,
        ),
        relapses: const [],
        hourlyRelapseDistribution: const [],
        relapseTriggerDistribution: const [],
        peakRelapseHoursUtc: const [22],
        peakRelapseCount: 2,
        aiSummary: 'Relapse malam hari',
      );

      when(
        () => mockRemoteDataSource.getRelapseStatistics(),
      ).thenAnswer((_) async => mockRelapseStats);

      final stats = await repository.getRelapseStatistics();
      expect(stats.peakRelapseHoursUtc, equals([22]));
      verify(() => mockRemoteDataSource.getRelapseStatistics()).called(1);
    });

    test('getRelapseSolution delegates to remote data source', () async {
      final mockSolution = RoutineRelapseSolutionData(
        title: 'Solusi Khusus',
        analysis: 'Analisis trigger',
        summary: 'Rencana aksi cepat',
      );

      when(
        () => mockRemoteDataSource.getRelapseSolution(
          mood: any(named: 'mood'),
          relapseTriggers: any(named: 'relapseTriggers'),
          commitment: any(named: 'commitment'),
        ),
      ).thenAnswer((_) async => mockSolution);

      final solution = await repository.getRelapseSolution(
        mood: 'cemas',
        relapseTriggers: ['stres'],
        commitment: 'Komitmen baru',
      );

      expect(solution.title, equals('Solusi Khusus'));
      verify(
        () => mockRemoteDataSource.getRelapseSolution(
          mood: 'cemas',
          relapseTriggers: ['stres'],
          commitment: 'Komitmen baru',
        ),
      ).called(1);
    });
  });
}
