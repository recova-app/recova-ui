import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/features/community/presentation/cubit/community_cubit.dart';
import 'package:recova/features/education/presentation/cubit/education_cubit.dart';
import 'package:recova/features/home/presentation/cubit/home_cubit.dart';
import 'package:recova/features/routine/presentation/cubit/checkin_cubit.dart';
import 'package:recova/features/routine/presentation/cubit/relapse_cubit.dart';
import 'package:recova/features/routine/presentation/cubit/stats_cubit.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/models/daily_content_model.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/user_model.dart';
import 'package:recova/pages/main_scaffold.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockStatsCubit extends MockCubit<StatsState> implements StatsCubit {}

class MockEducationCubit extends MockCubit<EducationState>
    implements EducationCubit {}

class MockCommunityCubit extends MockCubit<CommunityState>
    implements CommunityCubit {}

class MockCheckinCubit extends MockCubit<CheckinState>
    implements CheckinCubit {}

class MockRelapseCubit extends MockCubit<RelapseState>
    implements RelapseCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockStatsCubit mockStatsCubit;
  late MockEducationCubit mockEducationCubit;
  late MockCommunityCubit mockCommunityCubit;
  late MockCheckinCubit mockCheckinCubit;
  late MockRelapseCubit mockRelapseCubit;

  final testUser = User(
    id: '1',
    email: 'test@example.com',
    nickname: 'TestUser',
    dailyCheckinTime: '21:00',
    pornFreeGoal: 30,
    recoveryReason: 'Sehat selalu',
  );

  final testStats = Statistics(
    currentStreak: 5,
    longestStreak: 10,
    totalCheckins: 20,
    streakCalendar: const ['2026-10-15'],
  );

  final sampleStatsResponse = RelapseStatisticsResponse(
    statistics: RelapseStats(
      currentStreak: 15,
      longestStreak: 20,
      totalCheckins: 30,
      totalAttempts: 35,
      successRate: 0.85,
      relapseCount: 5,
      relapseRate: 0.15,
      recoverySuccessRate: 0.85,
      checkinConsistencyScore: 0.9,
      moodTrend: const [],
      streakCalendar: const ['2026-05-10'],
      relapseCalendar: const [],
    ),
    relapses: const [],
    hourlyRelapseDistribution: const [],
    peakRelapseHoursUtc: const [],
    peakRelapseCount: 0,
    aiSummary: '',
    relapseTriggerDistribution: const [],
  );

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockStatsCubit = MockStatsCubit();
    mockEducationCubit = MockEducationCubit();
    mockCommunityCubit = MockCommunityCubit();
    mockCheckinCubit = MockCheckinCubit();
    mockRelapseCubit = MockRelapseCubit();

    when(() => mockHomeCubit.state).thenReturn(
      HomeLoadSuccess(
        user: testUser,
        statistics: testStats,
        relapseCalendar: const [],
        dailyContent: const DailyContent(
          date: '2026-10-15',
          motivation: 'Tetap kuat',
        ),
      ),
    );
    when(() => mockHomeCubit.fetchHomeData()).thenAnswer((_) async {});

    when(
      () => mockStatsCubit.state,
    ).thenReturn(StatsLoadSuccess(data: sampleStatsResponse));
    when(() => mockStatsCubit.fetchStats()).thenAnswer((_) async {});

    when(
      () => mockEducationCubit.state,
    ).thenReturn(const EducationLoadSuccess([]));
    when(
      () => mockEducationCubit.fetchEducationContents(),
    ).thenAnswer((_) async {});

    when(
      () => mockCommunityCubit.state,
    ).thenReturn(const CommunityLoadSuccess([]));
    when(() => mockCommunityCubit.fetchPosts()).thenAnswer((_) async {});
  });

  Widget buildScaffold() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>.value(value: mockHomeCubit),
        BlocProvider<StatsCubit>.value(value: mockStatsCubit),
        BlocProvider<EducationCubit>.value(value: mockEducationCubit),
        BlocProvider<CommunityCubit>.value(value: mockCommunityCubit),
        BlocProvider<CheckinCubit>.value(value: mockCheckinCubit),
        BlocProvider<RelapseCubit>.value(value: mockRelapseCubit),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const MainScaffold(),
      ),
    );
  }

  testWidgets(
    'MainScaffold renders and switches between all 5 bottom nav tabs',
    (tester) async {
      await tester.pumpWidget(buildScaffold());
      await tester.pumpAndSettle();

      // 1. Initial tab: Beranda
      expect(find.text('Halo, TestUser!'), findsOneWidget);

      // 2. Tab: Statistik
      await tester.tap(find.text('Statistik'));
      await tester.pumpAndSettle();
      expect(find.text('Statistik Kamu'), findsOneWidget);

      // 3. Tab: Bantuan (CommunityHub)
      await tester.tap(find.text('Bantuan'));
      await tester.pumpAndSettle();
      expect(find.text('Kamu tidak berjuang sendirian'), findsOneWidget);

      // 4. Tab: Edukasi
      await tester.tap(find.text('Edukasi'));
      await tester.pumpAndSettle();
      expect(find.text('Fitur Edukasi'), findsOneWidget);

      // 5. Tab: Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('TestUser'), findsOneWidget);
    },
  );
}
