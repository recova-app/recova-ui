import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/features/community/domain/repositories/community_repository.dart';
import 'package:recova/features/community/presentation/cubit/community_cubit.dart';
import 'package:recova/models/community_like_data.dart';
import 'package:recova/models/post_model.dart';

class MockCommunityRepository extends Mock implements CommunityRepository {}

void main() {
  group('CommunityCubit Feature Tests', () {
    late MockCommunityRepository mockRepository;

    final testPost = Post(
      id: 'post_001',
      title: 'Kisah Perjalanan',
      content: 'Hari ini genap 60 hari pulih.',
      category: 'cerita',
      commentCount: 5,
      likeCount: 20,
      createdAt: DateTime.parse('2026-05-10T12:00:00Z'),
      userId: 'user_001',
      username: 'pejuang_tangguh',
      userStreak: 60,
      isLiked: false,
    );

    setUp(() {
      mockRepository = MockCommunityRepository();
    });

    test('default constructor instantiates successfully', () {
      final cubit = CommunityCubit();
      expect(cubit.state, equals(CommunityInitial()));
      cubit.close();
    });

    blocTest<CommunityCubit, CommunityState>(
      'fetchPosts handles category filter parameter correctly',
      build: () {
        when(
          () => mockRepository.getPosts(category: 'cerita'),
        ).thenAnswer((_) async => [testPost]);
        return CommunityCubit(communityRepository: mockRepository);
      },
      act: (cubit) => cubit.fetchPosts(category: 'cerita'),
      expect:
          () => [
            CommunityLoading(),
            CommunityLoadSuccess([testPost]),
          ],
      verify: (_) {
        verify(() => mockRepository.getPosts(category: 'cerita')).called(1);
      },
    );

    blocTest<CommunityCubit, CommunityState>(
      'toggleLike does nothing when state is not CommunityLoadSuccess',
      build: () => CommunityCubit(communityRepository: mockRepository),
      act: (cubit) => cubit.toggleLike('post_001'),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockRepository.toggleLike(any()));
      },
    );

    blocTest<CommunityCubit, CommunityState>(
      'toggleLike does nothing when target postId is not in post list',
      build: () {
        final cubit = CommunityCubit(communityRepository: mockRepository);
        cubit.emit(CommunityLoadSuccess([testPost]));
        return cubit;
      },
      act: (cubit) => cubit.toggleLike('non_existent_post'),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockRepository.toggleLike(any()));
      },
    );

    blocTest<CommunityCubit, CommunityState>(
      'toggleLike optimistic toggle and sync updates cachedPosts',
      build: () {
        when(() => mockRepository.toggleLike('post_001')).thenAnswer(
          (_) async => const CommunityLikeData(likedCount: 21, isLiked: true),
        );
        final cubit = CommunityCubit(communityRepository: mockRepository);
        cubit.emit(CommunityLoadSuccess([testPost]));
        return cubit;
      },
      act: (cubit) => cubit.toggleLike('post_001'),
      verify: (cubit) {
        expect(cubit.cachedPosts.first.isLiked, isTrue);
        expect(cubit.cachedPosts.first.likeCount, 21);
      },
    );
  });
}
