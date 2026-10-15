import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/bloc/checkin_cubit.dart';
import 'package:recova/bloc/home_cubit.dart';
import 'package:recova/bloc/relapse_cubit.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/home/presentation/pages/home_page.dart';
import 'package:recova/models/daily_content_model.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/models/user_model.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockCheckinCubit extends MockCubit<CheckinState>
    implements CheckinCubit {}

class MockRelapseCubit extends MockCubit<RelapseState>
    implements RelapseCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockCheckinCubit mockCheckinCubit;
  late MockRelapseCubit mockRelapseCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockCheckinCubit = MockCheckinCubit();
    mockRelapseCubit = MockRelapseCubit();
  });

  Widget buildTestablePage({required Widget page}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>.value(value: mockHomeCubit),
          BlocProvider<CheckinCubit>.value(value: mockCheckinCubit),
          BlocProvider<RelapseCubit>.value(value: mockRelapseCubit),
        ],
        child: page,
      ),
    );
  }

  final testUser = User(
    id: 'user_123',
    nickname: 'Budi',
    email: 'budi@example.com',
    dailyCheckinTime: '18:00',
    pornFreeGoal: 30,
  );

  final testStatistics = Statistics(
    currentStreak: 7,
    longestStreak: 12,
    totalCheckins: 15,
    streakCalendar: const ['2026-05-10'],
    streakGoalComparison: StreakGoalComparison(
      currentStreak: 7,
      longestStreak: 12,
      pornFreeGoal: 30,
      goalReached: false,
      remainingDays: 23,
      progressRate: 0.23,
    ),
  );

  group('HomePage View Tests', () {
    testWidgets('renders loading indicator when state is HomeLoading', (
      tester,
    ) async {
      when(() => mockHomeCubit.state).thenReturn(HomeLoading());
      when(() => mockHomeCubit.fetchHomeData()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestablePage(page: const HomePage()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message and retry button when HomeLoadFailure', (
      tester,
    ) async {
      when(
        () => mockHomeCubit.state,
      ).thenReturn(const HomeLoadFailure('Koneksi internet terputus'));
      when(() => mockHomeCubit.fetchHomeData()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestablePage(page: const HomePage()));

      expect(find.text('Koneksi internet terputus'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      verify(() => mockHomeCubit.fetchHomeData()).called(greaterThan(0));
    });

    testWidgets('renders full dashboard on HomeLoadSuccess', (tester) async {
      when(() => mockHomeCubit.state).thenReturn(
        HomeLoadSuccess(
          user: testUser,
          statistics: testStatistics,
          dailyContent: const DailyContent(
            date: '2026-05-10',
            motivation: 'Konsistensi adalah kunci keberhasilan.',
          ),
          relapseCalendar: const [],
        ),
      );
      when(() => mockHomeCubit.fetchHomeData()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestablePage(page: const HomePage()));

      expect(find.text('Halo, Budi!'), findsOneWidget);
      expect(find.text('Streak Kamu'), findsOneWidget);
      expect(find.text('7 Hari'), findsOneWidget);
      expect(find.text('Daily Routine'), findsOneWidget);
      expect(find.text('Bantu Pemulihan'), findsOneWidget);
      expect(find.text('Insight Hari Ini'), findsOneWidget);
      expect(
        find.text('Konsistensi adalah kunci keberhasilan.'),
        findsOneWidget,
      );
    });
  });
}
