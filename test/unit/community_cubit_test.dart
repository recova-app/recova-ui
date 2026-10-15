import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/features/community/domain/repositories/community_repository.dart';
import 'package:recova/features/community/presentation/cubit/community_cubit.dart';
import 'package:recova/models/community_like_data.dart';
import 'package:recova/models/post_model.dart';

class MockCommunityRepository extends Mock implements CommunityRepository {}

void main() {
  group('CommunityCubit', () {
    late MockCommunityRepository mockRepository;

    final testPostA = Post(
      id: 'post_a',
      title: 'Post A',
      content: 'Konten Post A',
      category: 'saran',
      commentCount: 2,
      likeCount: 5,
      createdAt: DateTime.parse('2026-05-10T08:00:00Z'),
      userId: 'user_1',
      username: 'User 1',
      userStreak: 3,
      isLiked: false,
    );

    final testPostB = Post(
      id: 'post_b',
      title: 'Post B',
      content: 'Konten Post B',
      category: 'motivasi',
      commentCount: 0,
      likeCount: 10,
      createdAt: DateTime.parse('2026-05-10T09:00:00Z'),
      userId: 'user_2',
      username: 'User 2',
      userStreak: 7,
      isLiked: false,
    );

    setUp(() {
      mockRepository = MockCommunityRepository();
    });

    test('initial state is CommunityInitial', () {
      final cubit = CommunityCubit(communityRepository: mockRepository);
      expect(cubit.state, equals(CommunityInitial()));
      expect(cubit.cachedPosts, isEmpty);
    });

    blocTest<CommunityCubit, CommunityState>(
      'fetchPosts emits [CommunityLoading, CommunityLoadSuccess] on repository success',
      build: () {
        when(
          () => mockRepository.getPosts(category: any(named: 'category')),
        ).thenAnswer((_) async => [testPostA, testPostB]);
        return CommunityCubit(communityRepository: mockRepository);
      },
      act: (cubit) => cubit.fetchPosts(category: 'saran'),
      expect:
          () => [
            CommunityLoading(),
            CommunityLoadSuccess([testPostA, testPostB]),
          ],
      verify: (_) {
        verify(() => mockRepository.getPosts(category: 'saran')).called(1);
      },
    );

    blocTest<CommunityCubit, CommunityState>(
      'fetchPosts emits [CommunityLoading, CommunityLoadFailure] on exception',
      build: () {
        when(
          () => mockRepository.getPosts(category: any(named: 'category')),
        ).thenThrow(Exception('Gagal memuat postingan'));
        return CommunityCubit(communityRepository: mockRepository);
      },
      act: (cubit) => cubit.fetchPosts(),
      expect:
          () => [
            CommunityLoading(),
            const CommunityLoadFailure('Gagal memuat postingan'),
          ],
    );

    blocTest<CommunityCubit, CommunityState>(
      'createPost emits [CommunitySubmitting, CommunitySubmitSuccess, CommunityLoading, CommunityLoadSuccess]',
      build: () {
        when(
          () => mockRepository.createPost(
            title: any(named: 'title'),
            content: any(named: 'content'),
            category: any(named: 'category'),
          ),
        ).thenAnswer((_) async => testPostA);
        when(
          () => mockRepository.getPosts(category: any(named: 'category')),
        ).thenAnswer((_) async => [testPostA]);
        return CommunityCubit(communityRepository: mockRepository);
      },
      act:
          (cubit) => cubit.createPost(
            title: 'Judul Baru',
            content: 'Isi Baru',
            category: 'saran',
          ),
      expect:
          () => [
            const CommunitySubmitting([]),
            const CommunitySubmitSuccess([]),
            CommunityLoading(),
            CommunityLoadSuccess([testPostA]),
          ],
    );

    blocTest<CommunityCubit, CommunityState>(
      'createPost emits [CommunitySubmitting, CommunitySubmitFailure] on error',
      build: () {
        when(
          () => mockRepository.createPost(
            title: any(named: 'title'),
            content: any(named: 'content'),
            category: any(named: 'category'),
          ),
        ).thenThrow(Exception('Gagal membuat'));
        return CommunityCubit(communityRepository: mockRepository);
      },
      act:
          (cubit) => cubit.createPost(
            title: 'Judul Baru',
            content: 'Isi Baru',
            category: 'saran',
          ),
      expect:
          () => [
            const CommunitySubmitting([]),
            const CommunitySubmitFailure('Gagal membuat', []),
          ],
    );

    test(
      'toggleLike performs optimistic like increment and status toggle, then syncs with server response',
      () async {
        when(() => mockRepository.toggleLike('post_a')).thenAnswer(
          (_) async => const CommunityLikeData(likedCount: 7, isLiked: true),
        );

        final cubit = CommunityCubit(communityRepository: mockRepository);

        // Pre-populate with loaded state
        cubit.emit(CommunityLoadSuccess([testPostA, testPostB]));

        final states = <CommunityState>[];
        final subscription = cubit.stream.listen(states.add);

        await cubit.toggleLike('post_a');
        await Future.delayed(const Duration(milliseconds: 10));

        expect(states.length, 2);
        // Optimistic state
        final optimisticState = states[0] as CommunityLoadSuccess;
        expect(optimisticState.posts[0].isLiked, isTrue);
        expect(optimisticState.posts[0].likeCount, 6);
        expect(optimisticState.posts[1].isLiked, isFalse);
        expect(optimisticState.posts[1].likeCount, 10);

        // Synchronized state with server response (e.g. server count updated)
        final syncedState = states[1] as CommunityLoadSuccess;
        expect(syncedState.posts[0].isLiked, isTrue);
        expect(syncedState.posts[0].likeCount, 7);
        expect(syncedState.posts[1].isLiked, isFalse);
        expect(syncedState.posts[1].likeCount, 10);

        await subscription.cancel();
      },
    );

    test(
      'toggleLike performs optimistic unlike decrement when post is already liked',
      () async {
        final likedPostA = testPostA.copyWith(isLiked: true, likeCount: 6);
        when(() => mockRepository.toggleLike('post_a')).thenAnswer(
          (_) async => const CommunityLikeData(likedCount: 4, isLiked: false),
        );

        final cubit = CommunityCubit(communityRepository: mockRepository);
        cubit.emit(CommunityLoadSuccess([likedPostA]));

        final states = <CommunityState>[];
        final subscription = cubit.stream.listen(states.add);

        await cubit.toggleLike('post_a');
        await Future.delayed(const Duration(milliseconds: 10));

        expect(states.length, 2);
        // Optimistic state
        final optimisticState = states[0] as CommunityLoadSuccess;
        expect(optimisticState.posts[0].isLiked, isFalse);
        expect(optimisticState.posts[0].likeCount, 5);

        // Synced state
        final syncedState = states[1] as CommunityLoadSuccess;
        expect(syncedState.posts[0].isLiked, isFalse);
        expect(syncedState.posts[0].likeCount, 4);

        await subscription.cancel();
      },
    );

    test(
      'toggleLike reverts ONLY targeted post when server call fails without resetting other posts',
      () async {
        when(
          () => mockRepository.toggleLike('post_a'),
        ).thenThrow(Exception('Jaringan terputus'));

        final cubit = CommunityCubit(communityRepository: mockRepository);
        cubit.emit(CommunityLoadSuccess([testPostA, testPostB]));

        final states = <CommunityState>[];
        final subscription = cubit.stream.listen(states.add);

        await cubit.toggleLike('post_a');
        await Future.delayed(const Duration(milliseconds: 10));

        expect(states.length, 2);
        // Optimistic state
        final optimistic = states[0] as CommunityLoadSuccess;
        expect(optimistic.posts[0].isLiked, isTrue);
        expect(optimistic.posts[0].likeCount, 6);

        // Reverted state: Post A reverted to original, Post B untouched
        final reverted = states[1] as CommunityLoadSuccess;
        expect(reverted.posts[0].isLiked, isFalse);
        expect(reverted.posts[0].likeCount, 5);
        expect(reverted.posts[1].isLiked, isFalse);
        expect(reverted.posts[1].likeCount, 10);

        await subscription.cancel();
      },
    );

    test(
      'concurrency test: when request A fails while request B is pending, only post A is reverted and post B updates persist',
      () async {
        final completerA = Completer<CommunityLikeData>();
        final completerB = Completer<CommunityLikeData>();

        when(
          () => mockRepository.toggleLike('post_a'),
        ).thenAnswer((_) => completerA.future);
        when(
          () => mockRepository.toggleLike('post_b'),
        ).thenAnswer((_) => completerB.future);

        final cubit = CommunityCubit(communityRepository: mockRepository);
        cubit.emit(CommunityLoadSuccess([testPostA, testPostB]));

        final states = <CommunityState>[];
        final subscription = cubit.stream.listen(states.add);

        // 1. User taps like on Post A
        final futureA = cubit.toggleLike('post_a');
        await Future.delayed(Duration.zero);

        // Assert optimistic update for Post A
        expect(cubit.state.posts[0].isLiked, isTrue);
        expect(cubit.state.posts[0].likeCount, 6);
        expect(cubit.state.posts[1].isLiked, isFalse);
        expect(cubit.state.posts[1].likeCount, 10);

        // 2. User taps like on Post B while request A is still in flight
        final futureB = cubit.toggleLike('post_b');
        await Future.delayed(Duration.zero);

        // Assert optimistic update for both posts
        expect(cubit.state.posts[0].isLiked, isTrue);
        expect(cubit.state.posts[0].likeCount, 6);
        expect(cubit.state.posts[1].isLiked, isTrue);
        expect(cubit.state.posts[1].likeCount, 11);

        // 3. Request A fails with network exception
        completerA.completeError(Exception('Network timeout on post A'));
        await futureA;
        await Future.delayed(Duration.zero);

        // CRITICAL ASSERTION: Post A must be reverted to (false, 5), but Post B must NOT be wiped out!
        expect(cubit.state.posts[0].isLiked, isFalse);
        expect(cubit.state.posts[0].likeCount, 5);
        expect(cubit.state.posts[1].isLiked, isTrue);
        expect(cubit.state.posts[1].likeCount, 11);

        // 4. Request B succeeds
        completerB.complete(
          const CommunityLikeData(likedCount: 11, isLiked: true),
        );
        await futureB;
        await Future.delayed(Duration.zero);

        // CRITICAL ASSERTION: Post A remains reverted (false, 5), Post B confirmed by server (true, 11)
        expect(cubit.state.posts[0].isLiked, isFalse);
        expect(cubit.state.posts[0].likeCount, 5);
        expect(cubit.state.posts[1].isLiked, isTrue);
        expect(cubit.state.posts[1].likeCount, 11);

        await subscription.cancel();
      },
    );

    test(
      'ignores duplicate toggleLike invocations on the same post while request is in flight',
      () async {
        final completer = Completer<CommunityLikeData>();
        when(
          () => mockRepository.toggleLike('post_a'),
        ).thenAnswer((_) => completer.future);

        final cubit = CommunityCubit(communityRepository: mockRepository);
        cubit.emit(CommunityLoadSuccess([testPostA]));

        final future1 = cubit.toggleLike('post_a');
        final future2 = cubit.toggleLike('post_a');

        await Future.delayed(Duration.zero);
        expect(cubit.state.posts.first.likeCount, 6);

        completer.complete(
          const CommunityLikeData(likedCount: 6, isLiked: true),
        );
        await future1;
        await future2;

        verify(() => mockRepository.toggleLike('post_a')).called(1);
      },
    );
  });
}
