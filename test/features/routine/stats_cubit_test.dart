import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/features/routine/domain/repositories/routine_repository.dart';
import 'package:recova/features/routine/presentation/cubit/stats_cubit.dart';
import 'package:recova/models/relapse_statistics_model.dart';

class MockRoutineRepository extends Mock implements RoutineRepository {}

void main() {
  late MockRoutineRepository mockRoutineRepository;

  final dummyStatsResponse = RelapseStatisticsResponse.fromJson(const {});

  setUp(() {
    mockRoutineRepository = MockRoutineRepository();
  });

  group('StatsCubit Feature Tests', () {
    test('initial state is StatsInitial', () {
      final cubit = StatsCubit(routineRepository: mockRoutineRepository);
      expect(cubit.state, isA<StatsInitial>());
      cubit.close();
    });

    blocTest<StatsCubit, StatsState>(
      'fetchStats emits [StatsLoading, StatsLoadSuccess] on repository success',
      build: () {
        when(
          () => mockRoutineRepository.getRelapseStatistics(),
        ).thenAnswer((_) async => dummyStatsResponse);
        return StatsCubit(routineRepository: mockRoutineRepository);
      },
      act: (cubit) => cubit.fetchStats(),
      expect: () => [isA<StatsLoading>(), isA<StatsLoadSuccess>()],
      verify: (_) {
        verify(() => mockRoutineRepository.getRelapseStatistics()).called(1);
      },
    );

    blocTest<StatsCubit, StatsState>(
      'fetchStats emits [StatsLoading, StatsLoadFailure] on repository error',
      build: () {
        when(
          () => mockRoutineRepository.getRelapseStatistics(),
        ).thenThrow(Exception('Network error'));
        return StatsCubit(routineRepository: mockRoutineRepository);
      },
      act: (cubit) => cubit.fetchStats(),
      expect:
          () => [
            isA<StatsLoading>(),
            isA<StatsLoadFailure>().having(
              (s) => s.error,
              'error',
              'Network error',
            ),
          ],
      verify: (_) {
        verify(() => mockRoutineRepository.getRelapseStatistics()).called(1);
      },
    );
  });
}
