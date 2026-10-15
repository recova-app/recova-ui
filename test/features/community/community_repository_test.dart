import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:recova/core/config/app_config.dart';
import 'package:recova/core/network/api_client.dart';
import 'package:recova/features/community/data/datasources/community_remote_data_source.dart';
import 'package:recova/features/community/data/repositories/community_repository_impl.dart';
import 'package:recova/features/community/domain/repositories/community_repository.dart';
import 'package:recova/models/community_like_data.dart';
import 'package:recova/models/post_model.dart';

class MockCommunityRemoteDataSource extends Mock
    implements CommunityRemoteDataSource {}

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

  group('CommunityRemoteDataSourceImpl', () {
    test(
      'getPosts sends GET /community without category param when null or all',
      () async {
        late http.BaseRequest capturedRequest;
        final fakeClient = FakeHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Postingan berhasil diambil',
              'data': [
                {
                  'id': 'post_100',
                  'title': 'Tips Konsistensi',
                  'content': 'Bagaimana menjaga komitmen harian',
                  'category': 'saran',
                  'comment_count': 4,
                  'like_count': 12,
                  'created_at': '2026-05-10T12:00:00Z',
                  'is_liked': true,
                  'author': {
                    'id': 'user_99',
                    'nickname': 'Pejuang Pulih',
                    'current_streak': 15,
                  },
                },
              ],
              'meta': null,
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final apiClient = ApiClient(
          client: fakeClient,
          config: testConfig,
          tokenProvider: () async => 'test_token',
        );
        final dataSource = CommunityRemoteDataSourceImpl(apiClient: apiClient);

        final posts = await dataSource.getPosts();

        expect(capturedRequest.method, 'GET');
        expect(capturedRequest.url.path, '/api/v1/community');
        expect(
          capturedRequest.url.queryParameters.containsKey('category'),
          isFalse,
        );
        expect(capturedRequest.headers['Authorization'], 'Bearer test_token');

        expect(posts.length, 1);
        expect(posts.first.id, 'post_100');
        expect(posts.first.title, 'Tips Konsistensi');
        expect(posts.first.content, 'Bagaimana menjaga komitmen harian');
        expect(posts.first.category, 'saran');
        expect(posts.first.commentCount, 4);
        expect(posts.first.likeCount, 12);
        expect(posts.first.isLiked, isTrue);
        expect(posts.first.username, 'Pejuang Pulih');
        expect(posts.first.userStreak, 15);
      },
    );

    test(
      'getPosts normalizes category query param when category is passed',
      () async {
        late http.BaseRequest capturedRequest;
        final fakeClient = FakeHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'OK',
              'data': [],
              'meta': null,
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final apiClient = ApiClient(
          client: fakeClient,
          config: testConfig,
          tokenProvider: () async => null,
        );
        final dataSource = CommunityRemoteDataSourceImpl(apiClient: apiClient);

        await dataSource.getPosts(category: 'Nasihat');

        expect(capturedRequest.method, 'GET');
        expect(capturedRequest.url.path, '/api/v1/community');
        expect(capturedRequest.url.queryParameters['category'], 'saran');
      },
    );

    test(
      'createPost sends POST /community with title, content, and normalized category',
      () async {
        late http.BaseRequest capturedRequest;
        final fakeClient = FakeHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Postingan dibuat',
              'data': {
                'id': 'post_new_1',
                'title': 'Pengalaman Hari ke-30',
                'content': 'Sangat bersyukur bisa sampai titik ini',
                'category': 'cerita',
                'comment_count': 0,
                'like_count': 0,
                'created_at': '2026-05-10T14:00:00Z',
                'author': {
                  'id': 'user_me',
                  'nickname': 'Aku Bisa',
                  'current_streak': 30,
                },
              },
              'meta': null,
            }),
            201,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final apiClient = ApiClient(
          client: fakeClient,
          config: testConfig,
          tokenProvider: () async => 'token_123',
        );
        final dataSource = CommunityRemoteDataSourceImpl(apiClient: apiClient);

        final created = await dataSource.createPost(
          title: 'Pengalaman Hari ke-30',
          content: 'Sangat bersyukur bisa sampai titik ini',
          category: 'Story',
        );

        expect(capturedRequest.method, 'POST');
        expect(capturedRequest.url.path, '/api/v1/community');

        final body = jsonDecode((capturedRequest as http.Request).body);
        expect(body['title'], 'Pengalaman Hari ke-30');
        expect(body['content'], 'Sangat bersyukur bisa sampai titik ini');
        expect(body['category'], 'cerita');

        expect(created.id, 'post_new_1');
        expect(created.category, 'cerita');
        expect(created.username, 'Aku Bisa');
        expect(created.userStreak, 30);
      },
    );

    test(
      'toggleLike sends POST /community/{post_id}/like and deserializes CommunityLikeData',
      () async {
        late http.BaseRequest capturedRequest;
        final fakeClient = FakeHttpClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Postingan berhasil disukai',
              'data': {'liked_count': 11, 'is_liked': true},
              'meta': null,
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final apiClient = ApiClient(
          client: fakeClient,
          config: testConfig,
          tokenProvider: () async => 'token_xyz',
        );
        final dataSource = CommunityRemoteDataSourceImpl(apiClient: apiClient);

        final result = await dataSource.toggleLike('post_abc');

        expect(capturedRequest.method, 'POST');
        expect(capturedRequest.url.path, '/api/v1/community/post_abc/like');
        expect(result.likedCount, 11);
        expect(result.isLiked, isTrue);
      },
    );

    test('toggleLike maps 401 response into UnauthorizedException', () async {
      final fakeClient = FakeHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Token kadaluarsa',
            'data': null,
            'error': {
              'code': 'UNAUTHENTICATED',
              'details': null,
              'request_id': 'req_401',
            },
          }),
          401,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiClient = ApiClient(client: fakeClient, config: testConfig);
      final dataSource = CommunityRemoteDataSourceImpl(apiClient: apiClient);

      expect(
        () => dataSource.toggleLike('post_123'),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('CommunityRepositoryImpl', () {
    late MockCommunityRemoteDataSource mockRemoteDataSource;
    late CommunityRepository repository;

    final testPost = Post(
      id: 'post_1',
      title: 'Judul',
      content: 'Isi',
      category: 'saran',
      commentCount: 1,
      likeCount: 2,
      createdAt: DateTime.parse('2026-05-10T10:00:00Z'),
      userId: 'user_1',
      username: 'User 1',
      userStreak: 5,
      isLiked: false,
    );

    setUp(() {
      mockRemoteDataSource = MockCommunityRemoteDataSource();
      repository = CommunityRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    test('getPosts delegates to remote data source', () async {
      when(
        () => mockRemoteDataSource.getPosts(category: any(named: 'category')),
      ).thenAnswer((_) async => [testPost]);

      final result = await repository.getPosts(category: 'saran');

      expect(result, equals([testPost]));
      verify(() => mockRemoteDataSource.getPosts(category: 'saran')).called(1);
    });

    test('createPost delegates to remote data source', () async {
      when(
        () => mockRemoteDataSource.createPost(
          title: any(named: 'title'),
          content: any(named: 'content'),
          category: any(named: 'category'),
        ),
      ).thenAnswer((_) async => testPost);

      final result = await repository.createPost(
        title: 'Judul',
        content: 'Isi',
        category: 'saran',
      );

      expect(result, equals(testPost));
      verify(
        () => mockRemoteDataSource.createPost(
          title: 'Judul',
          content: 'Isi',
          category: 'saran',
        ),
      ).called(1);
    });

    test('toggleLike delegates to remote data source', () async {
      const likeData = CommunityLikeData(likedCount: 3, isLiked: true);
      when(
        () => mockRemoteDataSource.toggleLike('post_1'),
      ).thenAnswer((_) async => likeData);

      final result = await repository.toggleLike('post_1');

      expect(result, equals(likeData));
      verify(() => mockRemoteDataSource.toggleLike('post_1')).called(1);
    });
  });
}
