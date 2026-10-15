import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/features/routine/domain/repositories/routine_repository.dart';
import 'package:recova/features/routine/presentation/cubit/checkin_cubit.dart';
import 'package:recova/models/checkin_result_model.dart';
import 'package:recova/models/statistics_model.dart';

class MockRoutineRepository extends Mock implements RoutineRepository {}

class MockHomeCubit extends Mock implements HomeCubit {}

void main() {
  group('CheckinCubit', () {
    late MockRoutineRepository mockRepository;
    late MockHomeCubit mockHomeCubit;

    setUp(() {
      mockRepository = MockRoutineRepository();
      mockHomeCubit = MockHomeCubit();
    });

    final testCheckInResult = CheckInResult(
      id: 'checkin_001',
      startDate: DateTime.parse('2026-05-10T08:00:00Z'),
      isActive: true,
      checkIn: RoutineCheckInData(
        id: 'checkin_001',
        userId: 'user_001',
        checkInDate: '2026-05-10',
        checkInDayName: 'Sabtu',
        mood: 'bahagia',
        isSuccessful: true,
        commitment: 'Terus konsisten',
      ),
      statistics: Statistics(
        currentStreak: 10,
        longestStreak: 15,
        totalCheckins: 20,
        streakCalendar: const ['2026-05-10'],
      ),
    );

    test('initial state is CheckinInitial', () {
      final cubit = CheckinCubit(
        routineRepository: mockRepository,
        homeCubit: mockHomeCubit,
      );
      expect(cubit.state, equals(CheckinInitial()));
    });

    blocTest<CheckinCubit, CheckinState>(
      'emits CheckinFailure when content is empty without invoking repository',
      build:
          () => CheckinCubit(
            routineRepository: mockRepository,
            homeCubit: mockHomeCubit,
          ),
      act: (cubit) => cubit.performCheckIn(content: '', mood: 'bahagia'),
      expect: () => [const CheckinFailure('Isi jurnal terlebih dahulu')],
      verify: (_) {
        verifyNever(
          () => mockRepository.checkIn(
            content: any(named: 'content'),
            mood: any(named: 'mood'),
            commitment: any(named: 'commitment'),
          ),
        );
        verifyNever(() => mockHomeCubit.fetchHomeData());
      },
    );

    blocTest<CheckinCubit, CheckinState>(
      'emits [CheckinLoading, CheckinSuccess] and refreshes HomeCubit on success',
      build: () {
        when(
          () => mockRepository.checkIn(
            content: any(named: 'content'),
            mood: any(named: 'mood'),
            commitment: any(named: 'commitment'),
          ),
        ).thenAnswer((_) async => testCheckInResult);
        when(() => mockHomeCubit.fetchHomeData()).thenAnswer((_) async {});
        return CheckinCubit(
          routineRepository: mockRepository,
          homeCubit: mockHomeCubit,
        );
      },
      act:
          (cubit) => cubit.performCheckIn(
            content: 'Hari ini penuh makna',
            mood: 'bahagia',
            commitment: 'Terus konsisten',
          ),
      expect: () => [CheckinLoading(), CheckinSuccess(testCheckInResult)],
      verify: (_) {
        verify(
          () => mockRepository.checkIn(
            content: 'Hari ini penuh makna',
            mood: 'bahagia',
            commitment: 'Terus konsisten',
          ),
        ).called(1);
        verify(() => mockHomeCubit.fetchHomeData()).called(1);
      },
    );

    blocTest<CheckinCubit, CheckinState>(
      'emits [CheckinLoading, CheckinSuccess] when homeCubit is null without error',
      build: () {
        when(
          () => mockRepository.checkIn(
            content: any(named: 'content'),
            mood: any(named: 'mood'),
            commitment: any(named: 'commitment'),
          ),
        ).thenAnswer((_) async => testCheckInResult);
        return CheckinCubit(routineRepository: mockRepository, homeCubit: null);
      },
      act:
          (cubit) =>
              cubit.performCheckIn(content: 'Checkin mandiri', mood: 'tenang'),
      expect: () => [CheckinLoading(), CheckinSuccess(testCheckInResult)],
    );

    blocTest<CheckinCubit, CheckinState>(
      'emits [CheckinLoading, CheckinFailure] on repository exception',
      build: () {
        when(
          () => mockRepository.checkIn(
            content: any(named: 'content'),
            mood: any(named: 'mood'),
            commitment: any(named: 'commitment'),
          ),
        ).thenThrow(Exception('Koneksi timeout'));
        return CheckinCubit(
          routineRepository: mockRepository,
          homeCubit: mockHomeCubit,
        );
      },
      act:
          (cubit) =>
              cubit.performCheckIn(content: 'Catatan gagal', mood: 'bahagia'),
      expect: () => [CheckinLoading(), const CheckinFailure('Koneksi timeout')],
      verify: (_) {
        verifyNever(() => mockHomeCubit.fetchHomeData());
      },
    );

    test('resetState emits CheckinInitial', () {
      final cubit = CheckinCubit(
        routineRepository: mockRepository,
        homeCubit: mockHomeCubit,
      );
      cubit.emit(CheckinSuccess(testCheckInResult));
      expect(cubit.state, isA<CheckinSuccess>());

      cubit.resetState();
      expect(cubit.state, equals(CheckinInitial()));
    });
  });
}
