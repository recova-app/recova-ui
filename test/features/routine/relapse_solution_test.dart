import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/core/network/network_exceptions.dart';
import 'package:recova/features/routine/domain/repositories/routine_repository.dart';
import 'package:recova/features/routine/presentation/cubit/relapse_cubit.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/models/statistics_model.dart';

class MockRoutineRepository extends Mock implements RoutineRepository {}

class MockHomeCubit extends Mock implements HomeCubit {}

void main() {
  group('RelapseCubit and AI Relapse Solution Integration', () {
    late MockRoutineRepository mockRepository;
    late MockHomeCubit mockHomeCubit;

    setUp(() {
      mockRepository = MockRoutineRepository();
      mockHomeCubit = MockHomeCubit();
    });

    final testRelapseResult = CheckInResult(
      id: 'relapse_101',
      startDate: DateTime.parse('2026-05-10T21:00:00Z'),
      isActive: false,
      relapse: RoutineRelapseData(
        id: 'relapse_101',
        userId: 'user_101',
        relapseDate: '2026-05-10',
        relapseDayName: 'Sabtu',
        mood: 'cemas',
        commitment: 'Saya berjanji bangkit kembali',
        relapseTrigger: const ['stres kerja', 'sendirian malam'],
      ),
      statistics: Statistics(
        currentStreak: 0,
        longestStreak: 12,
        totalCheckins: 23,
        streakCalendar: const [],
      ),
      relapseSolution: null,
    );

    final testAiSolution = RoutineRelapseSolutionData(
      title: 'Pulihkan Fokus Sekarang',
      analysis: 'Pemicu utama muncul saat stres dan sendirian malam.',
      summary:
          'Putus akses ke perangkat, ambil nafas dalam 4-7-8, dan hubungi rekan akuntabilitas.',
      generatedAt: DateTime.parse('2026-05-10T21:05:00Z'),
    );

    test('initial state is RelapseInitial', () {
      final cubit = RelapseCubit(
        routineRepository: mockRepository,
        homeCubit: mockHomeCubit,
      );
      expect(cubit.state, equals(RelapseInitial()));
    });

    blocTest<RelapseCubit, RelapseState>(
      'emits RelapseFailure when mood is empty without calling repository',
      build:
          () => RelapseCubit(
            routineRepository: mockRepository,
            homeCubit: mockHomeCubit,
          ),
      act:
          (cubit) => cubit.submitRelapse(
            mood: '',
            relapseTriggers: ['stres'],
            commitment: 'Bangkit',
          ),
      expect: () => [const RelapseFailure('Pilih mood kamu terlebih dahulu')],
      verify: (_) {
        verifyNever(
          () => mockRepository.submitRelapse(
            mood: any(named: 'mood'),
            relapseTriggers: any(named: 'relapseTriggers'),
            commitment: any(named: 'commitment'),
            content: any(named: 'content'),
          ),
        );
      },
    );

    blocTest<RelapseCubit, RelapseState>(
      'emits RelapseFailure when relapse triggers list is empty',
      build:
          () => RelapseCubit(
            routineRepository: mockRepository,
            homeCubit: mockHomeCubit,
          ),
      act:
          (cubit) => cubit.submitRelapse(
            mood: 'cemas',
            relapseTriggers: [],
            commitment: 'Bangkit',
          ),
      expect: () => [const RelapseFailure('Pilih minimal satu pemicu relapse')],
    );

    blocTest<RelapseCubit, RelapseState>(
      'emits RelapseFailure when commitment is empty',
      build:
          () => RelapseCubit(
            routineRepository: mockRepository,
            homeCubit: mockHomeCubit,
          ),
      act:
          (cubit) => cubit.submitRelapse(
            mood: 'cemas',
            relapseTriggers: ['stres'],
            commitment: '',
          ),
      expect: () => [const RelapseFailure('Tulis pesan komitmen kamu')],
    );

    blocTest<RelapseCubit, RelapseState>(
      'submits relapse and invokes AI relapse solution endpoint on success',
      build: () {
        when(
          () => mockRepository.submitRelapse(
            mood: any(named: 'mood'),
            relapseTriggers: any(named: 'relapseTriggers'),
            commitment: any(named: 'commitment'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => testRelapseResult);

        when(
          () => mockRepository.getRelapseSolution(
            mood: any(named: 'mood'),
            relapseTriggers: any(named: 'relapseTriggers'),
            commitment: any(named: 'commitment'),
          ),
        ).thenAnswer((_) async => testAiSolution);

        when(() => mockHomeCubit.fetchHomeData()).thenAnswer((_) async {});

        return RelapseCubit(
          routineRepository: mockRepository,
          homeCubit: mockHomeCubit,
        );
      },
      act:
          (cubit) => cubit.submitRelapse(
            mood: 'cemas',
            relapseTriggers: ['stres kerja', 'sendirian malam'],
            commitment: 'Saya berjanji bangkit kembali',
          ),
      expect:
          () => [
            RelapseLoading(),
            RelapseSuccess(
              testRelapseResult.copyWith(relapseSolution: testAiSolution),
              aiSolution: testAiSolution,
            ),
          ],
      verify: (_) {
        verify(
          () => mockRepository.submitRelapse(
            mood: 'cemas',
            relapseTriggers: ['stres kerja', 'sendirian malam'],
            commitment: 'Saya berjanji bangkit kembali',
            content: 'Relapse report',
          ),
        ).called(1);

        verify(
          () => mockRepository.getRelapseSolution(
            mood: 'cemas',
            relapseTriggers: ['stres kerja', 'sendirian malam'],
            commitment: 'Saya berjanji bangkit kembali',
          ),
        ).called(1);

        verify(() => mockHomeCubit.fetchHomeData()).called(1);
      },
    );

    blocTest<RelapseCubit, RelapseState>(
      'falls back gracefully to default recovery guidance when AI service returns 502/503 server error',
      build: () {
        when(
          () => mockRepository.submitRelapse(
            mood: any(named: 'mood'),
            relapseTriggers: any(named: 'relapseTriggers'),
            commitment: any(named: 'commitment'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => testRelapseResult);

        when(
          () => mockRepository.getRelapseSolution(
            mood: any(named: 'mood'),
            relapseTriggers: any(named: 'relapseTriggers'),
            commitment: any(named: 'commitment'),
          ),
        ).thenThrow(
          const ServerException(
            message: 'Downstream AI gateway 502 Bad Gateway',
            statusCode: 502,
          ),
        );

        when(() => mockHomeCubit.fetchHomeData()).thenAnswer((_) async {});

        return RelapseCubit(
          routineRepository: mockRepository,
          homeCubit: mockHomeCubit,
        );
      },
      act:
          (cubit) => cubit.submitRelapse(
            mood: 'cemas',
            relapseTriggers: ['stres kerja'],
            commitment: 'Tetap berusaha',
          ),
      expect:
          () => [
            RelapseLoading(),
            predicate<RelapseState>((state) {
              if (state is! RelapseSuccess) return false;
              // Relapse submission must succeed despite AI failure
              expect(state.result.id, equals('relapse_101'));
              expect(state.result.isActive, isFalse);
              // Fallback solution must be populated
              expect(state.result.relapseSolution, isNotNull);
              expect(
                state.result.relapseSolution?.title,
                equals('Langkah Pemulihan'),
              );
              expect(state.aiSolution?.title, equals('Langkah Pemulihan'));
              return true;
            }),
          ],
      verify: (_) {
        verify(
          () => mockRepository.submitRelapse(
            mood: 'cemas',
            relapseTriggers: ['stres kerja'],
            commitment: 'Tetap berusaha',
            content: 'Relapse report',
          ),
        ).called(1);

        verify(
          () => mockRepository.getRelapseSolution(
            mood: 'cemas',
            relapseTriggers: ['stres kerja'],
            commitment: 'Tetap berusaha',
          ),
        ).called(1);

        verify(() => mockHomeCubit.fetchHomeData()).called(1);
      },
    );

    blocTest<RelapseCubit, RelapseState>(
      'preserves existing solution in relapse payload when AI endpoint fails',
      build: () {
        final existingSolution = RoutineRelapseSolutionData(
          title: 'Solusi Bawaan',
          analysis: 'Analisis dari respon server relapse',
          summary: 'Ringkasan dari respon server relapse',
        );
        final resultWithExisting = testRelapseResult.copyWith(
          relapseSolution: existingSolution,
        );

        when(
          () => mockRepository.submitRelapse(
            mood: any(named: 'mood'),
            relapseTriggers: any(named: 'relapseTriggers'),
            commitment: any(named: 'commitment'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => resultWithExisting);

        when(
          () => mockRepository.getRelapseSolution(
            mood: any(named: 'mood'),
            relapseTriggers: any(named: 'relapseTriggers'),
            commitment: any(named: 'commitment'),
          ),
        ).thenThrow(Exception('503 Service Unavailable'));

        when(() => mockHomeCubit.fetchHomeData()).thenAnswer((_) async {});

        return RelapseCubit(
          routineRepository: mockRepository,
          homeCubit: mockHomeCubit,
        );
      },
      act:
          (cubit) => cubit.submitRelapse(
            mood: 'cemas',
            relapseTriggers: ['stres kerja'],
            commitment: 'Bangkit lagi',
          ),
      expect:
          () => [
            RelapseLoading(),
            predicate<RelapseState>((state) {
              if (state is! RelapseSuccess) return false;
              expect(
                state.result.relapseSolution?.title,
                equals('Solusi Bawaan'),
              );
              return true;
            }),
          ],
    );

    blocTest<RelapseCubit, RelapseState>(
      'emits RelapseFailure when relapse submission fails without invoking AI solution',
      build: () {
        when(
          () => mockRepository.submitRelapse(
            mood: any(named: 'mood'),
            relapseTriggers: any(named: 'relapseTriggers'),
            commitment: any(named: 'commitment'),
            content: any(named: 'content'),
          ),
        ).thenThrow(Exception('Gagal mencatat relapse di server'));

        return RelapseCubit(
          routineRepository: mockRepository,
          homeCubit: mockHomeCubit,
        );
      },
      act:
          (cubit) => cubit.submitRelapse(
            mood: 'cemas',
            relapseTriggers: ['lelah'],
            commitment: 'Saya bersungguh-sungguh',
          ),
      expect:
          () => [
            RelapseLoading(),
            const RelapseFailure('Gagal mencatat relapse di server'),
          ],
      verify: (_) {
        verifyNever(
          () => mockRepository.getRelapseSolution(
            mood: any(named: 'mood'),
            relapseTriggers: any(named: 'relapseTriggers'),
            commitment: any(named: 'commitment'),
          ),
        );
        verifyNever(() => mockHomeCubit.fetchHomeData());
      },
    );

    test('resetState emits RelapseInitial', () {
      final cubit = RelapseCubit(
        routineRepository: mockRepository,
        homeCubit: mockHomeCubit,
      );
      cubit.emit(RelapseSuccess(testRelapseResult));
      expect(cubit.state, isA<RelapseSuccess>());

      cubit.resetState();
      expect(cubit.state, equals(RelapseInitial()));
    });
  });
}
