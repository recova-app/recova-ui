import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/routine/presentation/widgets/mood_selector.dart';
import 'package:recova/features/routine/presentation/widgets/relapse_trigger_selector.dart';
import 'package:recova/features/routine/presentation/widgets/routine_template_chips.dart';
import 'package:recova/features/routine/presentation/widgets/stats_history_panel.dart';
import 'package:recova/features/routine/presentation/widgets/stats_relapse_time_chart.dart';
import 'package:recova/features/routine/presentation/widgets/stats_streak_calendar.dart';
import 'package:recova/features/routine/presentation/widgets/stats_summary_cards.dart';
import 'package:recova/features/routine/presentation/widgets/stats_trigger_bar_chart.dart';
import 'package:recova/features/routine/presentation/widgets/streak_badge.dart';
import 'package:recova/models/relapse_statistics_model.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('MoodSelector Widget Tests', () {
    testWidgets('renders all default moods and responds to tap', (
      tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        buildTestableWidget(
          MoodSelector(
            selectedMood: 'baik',
            onMoodSelected: (val) {
              selected = val;
            },
          ),
        ),
      );

      expect(find.text('Baik'), findsOneWidget);
      expect(find.text('Biasa'), findsOneWidget);
      expect(find.text('Buruk'), findsOneWidget);
      expect(find.text('Sangat Baik'), findsOneWidget);
      expect(find.text('Sangat Buruk'), findsOneWidget);

      await tester.tap(find.text('Sangat Baik'));
      await tester.pumpAndSettle();

      expect(selected, equals('sangat_baik'));
    });

    testWidgets('does not trigger selection when disabled', (tester) async {
      String? selected;

      await tester.pumpWidget(
        buildTestableWidget(
          MoodSelector(
            selectedMood: 'baik',
            isEnabled: false,
            onMoodSelected: (val) {
              selected = val;
            },
          ),
        ),
      );

      await tester.tap(find.text('Sangat Baik'));
      await tester.pumpAndSettle();

      expect(selected, isNull);
    });
  });

  group('StreakBadge Widget Tests', () {
    testWidgets('renders animated streak count and quote', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const StreakBadge(
            title: 'Daily Check-In',
            streakDays: 21,
            subtitle: 'Hari Tanpa Pornografi',
            quote: '"Tetap teguh pada tujuanmu."',
          ),
        ),
      );

      expect(find.text('Daily Check-In'), findsOneWidget);
      expect(find.text('21'), findsOneWidget);
      expect(find.text('Hari Tanpa Pornografi'), findsOneWidget);
      expect(find.text('"Tetap teguh pada tujuanmu."'), findsOneWidget);
    });
  });

  group('RelapseTriggerSelector Widget Tests', () {
    testWidgets('renders triggers and allows toggling', (tester) async {
      String? toggledTrigger;

      await tester.pumpWidget(
        buildTestableWidget(
          RelapseTriggerSelector(
            selectedTriggers: const {'Stress'},
            onTriggerToggled: (trigger) {
              toggledTrigger = trigger;
            },
          ),
        ),
      );

      expect(find.text('Stress'), findsOneWidget);
      expect(find.text('Boredom'), findsOneWidget);
      expect(find.text('Media'), findsOneWidget);

      await tester.tap(find.text('Boredom'));
      await tester.pumpAndSettle();

      expect(toggledTrigger, equals('Boredom'));
    });
  });

  group('RoutineTemplateChips Widget Tests', () {
    testWidgets('appends tapped template to controller', (tester) async {
      final controller = TextEditingController(text: 'Awal');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestableWidget(
          RoutineTemplateChips(
            templates: const ['Template Pertama', 'Template Kedua'],
            isEnabled: true,
            controller: controller,
          ),
        ),
      );

      expect(find.text('Template Pertama'), findsOneWidget);

      await tester.tap(find.text('Template Pertama'));
      await tester.pumpAndSettle();

      expect(controller.text, equals('Awal Template Pertama'));
    });
  });

  group('StatsSummaryCards Widget Tests', () {
    testWidgets('renders summary numbers and labels', (tester) async {
      final stats = RelapseStats(
        currentStreak: 12,
        longestStreak: 45,
        totalCheckins: 80,
        totalAttempts: 90,
        successRate: 0.88,
        relapseCount: 10,
        relapseRate: 0.12,
        recoverySuccessRate: 0.88,
        checkinConsistencyScore: 0.9,
        moodTrend: const [],
        streakCalendar: const [],
        relapseCalendar: const [],
      );

      await tester.pumpWidget(
        buildTestableWidget(
          StatsSummaryCards(stats: stats, cleanDays: 70, successPercent: 88),
        ),
      );

      expect(find.text('Longest Streak'), findsOneWidget);
      expect(find.text('45 Hari'), findsOneWidget);
      expect(find.text('Success Rate'), findsOneWidget);
      expect(find.text('88%'), findsOneWidget);
      expect(find.text('Clean Days'), findsOneWidget);
      expect(find.text('70 Hari'), findsOneWidget);
      expect(find.text('Total Check-ins'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
    });
  });

  group('StatsStreakCalendar Widget Tests', () {
    testWidgets('renders month and allows navigation', (tester) async {
      final stats = RelapseStats(
        currentStreak: 5,
        longestStreak: 10,
        totalCheckins: 10,
        totalAttempts: 10,
        successRate: 1.0,
        relapseCount: 0,
        relapseRate: 0.0,
        recoverySuccessRate: 1.0,
        checkinConsistencyScore: 1.0,
        moodTrend: const [],
        streakCalendar: const ['2026-05-01', '2026-05-02'],
        relapseCalendar: const [],
      );

      DateTime currentMonth = DateTime(2026, 5);
      DateTime? changedMonth;

      await tester.pumpWidget(
        buildTestableWidget(
          StatsStreakCalendar(
            stats: stats,
            calendarMonth: currentMonth,
            onMonthChanged: (m) {
              changedMonth = m;
            },
          ),
        ),
      );

      expect(find.text('May 2026'), findsOneWidget);
      expect(find.text('Sen'), findsOneWidget);
      expect(find.text('Rab'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(changedMonth, equals(DateTime(2026, 6)));
    });
  });

  group('StatsHistoryPanel Widget Tests', () {
    testWidgets('renders empty state when no relapses', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const StatsHistoryPanel(relapses: [])),
      );

      expect(find.text('Belum ada relapse!'), findsOneWidget);
      expect(find.text('Pertahankan progresmu'), findsOneWidget);
    });

    testWidgets('renders timeline item with relapse details and triggers', (
      tester,
    ) async {
      final relapses = [
        RelapseEntry(
          id: 'rel_1',
          userId: 'user_1',
          relapseDate: '2026-05-08',
          relapseDayName: 'Jumat',
          mood: 'Buruk',
          commitment: 'Saya akan bangkit kembali!',
          relapseTrigger: const ['Stress', 'Boredom'],
          createdAt: '2026-05-08T12:00:00Z',
        ),
      ];

      await tester.pumpWidget(
        buildTestableWidget(StatsHistoryPanel(relapses: relapses)),
      );

      expect(find.text('Jumat, 2026-05-08'), findsOneWidget);
      expect(find.text('Mood: Buruk'), findsOneWidget);
      expect(find.text('Saya akan bangkit kembali!'), findsOneWidget);
      expect(find.text('Stress'), findsOneWidget);
      expect(find.text('Boredom'), findsOneWidget);
    });
  });
}
