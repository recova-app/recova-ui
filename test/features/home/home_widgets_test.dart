import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/home/presentation/widgets/daily_challenge_dialog.dart';
import 'package:recova/features/home/presentation/widgets/daily_motivation_card.dart';
import 'package:recova/features/home/presentation/widgets/home_feature_card.dart';
import 'package:recova/features/home/presentation/widgets/home_header.dart';
import 'package:recova/features/home/presentation/widgets/streak_counter_card.dart';
import 'package:recova/models/daily_content_model.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('HomeHeader Widget Tests', () {
    testWidgets('renders user nickname and greeting', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const HomeHeader(nickname: 'Alex')),
      );

      expect(find.text('Halo, Alex!'), findsOneWidget);
      expect(
        find.text('Apapun usahamu hari ini, kami bangga kepadamu'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });

    testWidgets('triggers notification callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          HomeHeader(
            nickname: 'Jordan',
            onNotificationTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('HomeFeatureCard Widget Tests', () {
    testWidgets('renders title, subtitle, and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          HomeFeatureCard(
            title: 'Emergency Button',
            subtitle: 'Bantuan instan saat tergoda',
            assetPath: 'assets/images/maskots/emergency.png',
            arrow: true,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      expect(find.text('Emergency Button'), findsOneWidget);
      expect(find.text('Bantuan instan saat tergoda'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.byType(HomeFeatureCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('StreakCounterCard Widget Tests', () {
    testWidgets('renders streak count, goal progress, and 7-day row', (
      tester,
    ) async {
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await tester.pumpWidget(
        buildTestableWidget(
          StreakCounterCard(
            currentStreak: 14,
            progress: 0.46,
            streakCalendar: [todayStr],
            relapseCalendar: const [],
            goalDays: 30,
          ),
        ),
      );

      expect(find.text('Streak Kamu'), findsOneWidget);
      expect(find.text('14 Hari'), findsOneWidget);
      expect(find.text('Progress: 14 / 30 Days'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('DailyMotivationCard Widget Tests', () {
    testWidgets('renders default motivation when daily content is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const DailyMotivationCard(dailyContent: null)),
      );

      expect(find.text('Insight Hari Ini'), findsOneWidget);
      expect(
        find.text(
          'Kamu sudah melakukan yang terbaik hari ini, hasil yang memuaskan datang dari hal kecil yang dilakukan secara konsisten.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders custom motivation and challenge details', (
      tester,
    ) async {
      final content = DailyContent(
        date: '2026-05-10',
        motivation: 'Setiap langkah maju adalah kemenangan berharga.',
        challenge: const DailyChallenge(
          title: 'Olahraga 15 Menit',
          description: 'Lakukan stretching ringan untuk merilekskan pikiran.',
        ),
      );

      await tester.pumpWidget(
        buildTestableWidget(DailyMotivationCard(dailyContent: content)),
      );

      expect(
        find.text('Setiap langkah maju adalah kemenangan berharga.'),
        findsOneWidget,
      );
      expect(find.text('Olahraga 15 Menit'), findsOneWidget);
      expect(
        find.text('Lakukan stretching ringan untuk merilekskan pikiran.'),
        findsOneWidget,
      );
    });
  });

  group('DailyChallengeDialog Widget Tests', () {
    testWidgets('renders challenge modal with title and description', (
      tester,
    ) async {
      const challenge = DailyChallenge(
        title: 'Membaca Buku',
        description: 'Baca satu bab buku pengembangan diri.',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: DailyChallengeDialog(challenge: challenge),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daily Activity\nChallenge'), findsOneWidget);
      expect(find.text('Membaca Buku'), findsOneWidget);
      expect(
        find.text('Baca satu bab buku pengembangan diri.'),
        findsOneWidget,
      );
      expect(find.text('Tutup'), findsOneWidget);
    });
  });
}
