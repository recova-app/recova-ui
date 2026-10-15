import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/bloc/stats_cubit.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/routine/presentation/cubit/checkin_cubit.dart';
import 'package:recova/features/routine/presentation/cubit/relapse_cubit.dart';
import 'package:recova/features/routine/presentation/pages/checkin_page.dart';
import 'package:recova/features/routine/presentation/pages/relapse_page.dart';
import 'package:recova/features/routine/presentation/pages/stats_page.dart';
import 'package:recova/models/relapse_statistics_model.dart';

class MockCheckinCubit extends MockCubit<CheckinState>
    implements CheckinCubit {}

class MockRelapseCubit extends MockCubit<RelapseState>
    implements RelapseCubit {}

class MockStatsCubit extends MockCubit<StatsState> implements StatsCubit {}

void main() {
  late MockCheckinCubit mockCheckinCubit;
  late MockRelapseCubit mockRelapseCubit;
  late MockStatsCubit mockStatsCubit;

  setUp(() {
    mockCheckinCubit = MockCheckinCubit();
    mockRelapseCubit = MockRelapseCubit();
    mockStatsCubit = MockStatsCubit();
  });

  Widget buildTestableApp({required Widget home}) {
    return MaterialApp(theme: AppTheme.lightTheme, home: home);
  }

  group('CheckInPage View Tests', () {
    testWidgets('renders check-in header, mood section, and submit button', (
      tester,
    ) async {
      when(() => mockCheckinCubit.state).thenReturn(CheckinInitial());

      await tester.pumpWidget(
        buildTestableApp(
          home: BlocProvider<CheckinCubit>.value(
            value: mockCheckinCubit,
            child: const CheckInPage(streakDays: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Check-In'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Bagaimana Mood Kamu?'), findsOneWidget);
      expect(find.text('Jurnal Harian'), findsOneWidget);
      expect(find.text('Check In Sekarang'), findsOneWidget);
    });

    testWidgets(
      'shows warning snackbar when submitting without selecting mood',
      (tester) async {
        when(() => mockCheckinCubit.state).thenReturn(CheckinInitial());

        await tester.pumpWidget(
          buildTestableApp(
            home: BlocProvider<CheckinCubit>.value(
              value: mockCheckinCubit,
              child: const CheckInPage(streakDays: 5),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final submitBtn = find.text('Check In Sekarang');
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(find.text('Pilih mood kamu terlebih dahulu'), findsOneWidget);
      },
    );
  });

  group('RelapsePage View Tests', () {
    testWidgets('renders relapse badge, mood, triggers, and action button', (
      tester,
    ) async {
      when(() => mockRelapseCubit.state).thenReturn(RelapseInitial());

      await tester.pumpWidget(
        buildTestableApp(
          home: BlocProvider<RelapseCubit>.value(
            value: mockRelapseCubit,
            child: const RelapsePage(streakDays: 12),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tidak Apa-Apa'), findsOneWidget);
      expect(find.text('Jatuh bukan berarti gagal'), findsOneWidget);
      expect(find.text('Apa Pemicu Relapse?'), findsOneWidget);
      expect(find.text('Pesan Komitmen'), findsOneWidget);
      expect(find.text('Akui & Reset Progress'), findsOneWidget);
    });

    testWidgets('shows warning snackbar when submitting without mood', (
      tester,
    ) async {
      when(() => mockRelapseCubit.state).thenReturn(RelapseInitial());

      await tester.pumpWidget(
        buildTestableApp(
          home: BlocProvider<RelapseCubit>.value(
            value: mockRelapseCubit,
            child: const RelapsePage(streakDays: 12),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final submitBtn = find.text('Akui & Reset Progress');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Pilih mood kamu terlebih dahulu'), findsOneWidget);
    });
  });

  group('StatsPage View Tests', () {
    testWidgets('renders loading spinner when state is StatsLoading', (
      tester,
    ) async {
      when(() => mockStatsCubit.state).thenReturn(StatsLoading());
      when(() => mockStatsCubit.fetchStats()).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildTestableApp(
          home: BlocProvider<StatsCubit>.value(
            value: mockStatsCubit,
            child: const StatsPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders tabs and switches between Analisis and Histori', (
      tester,
    ) async {
      final sampleResponse = RelapseStatisticsResponse(
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

      when(
        () => mockStatsCubit.state,
      ).thenReturn(StatsLoadSuccess(data: sampleResponse));
      when(() => mockStatsCubit.fetchStats()).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildTestableApp(
          home: BlocProvider<StatsCubit>.value(
            value: mockStatsCubit,
            child: const StatsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Analisis'), findsOneWidget);
      expect(find.text('Histori Relapse'), findsOneWidget);
      expect(find.text('Statistik Kamu'), findsOneWidget);

      // Switch to Histori Relapse tab
      await tester.tap(find.text('Histori Relapse'));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada relapse!'), findsOneWidget);
    });
  });
}
