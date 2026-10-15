import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/profile/presentation/widgets/profile_bottom_sheets.dart';
import 'package:recova/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:recova/features/profile/presentation/widgets/profile_setting_card.dart';
import 'package:recova/features/profile/presentation/widgets/profile_sheet_scaffold.dart';
import 'package:recova/models/user_model.dart';

void main() {
  Widget buildTestableWidget(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('ProfileBottomSheets Utility Tests', () {
    test('format24h correctly converts 12h time strings to 24h format', () {
      expect(ProfileBottomSheets.format24h('7 pm'), '19:00');
      expect(ProfileBottomSheets.format24h('12 pm'), '12:00');
      expect(ProfileBottomSheets.format24h('12 am'), '00:00');
      expect(ProfileBottomSheets.format24h('9 am'), '09:00');
    });

    test('timeIndexFrom24h resolves expected index or defaults to 10 pm', () {
      expect(ProfileBottomSheets.timeIndexFrom24h('22:00'), 3);
      expect(ProfileBottomSheets.timeIndexFrom24h(null), 3);
      expect(ProfileBottomSheets.timeIndexFrom24h(''), 3);
    });

    test('goalIndexFromDays resolves goal index matching day counts', () {
      expect(ProfileBottomSheets.goalIndexFromDays(7), 0);
      expect(ProfileBottomSheets.goalIndexFromDays(14), 1);
      expect(ProfileBottomSheets.goalIndexFromDays(30), 2);
      expect(ProfileBottomSheets.goalIndexFromDays(null), 1);
    });
  });

  group('ProfileHeaderCard Widget Tests', () {
    testWidgets('renders user profile details and recovery reason', (
      tester,
    ) async {
      final user = User(
        id: '101',
        nickname: 'Alex Parker',
        email: 'alex@example.com',
        pornFreeGoal: 30,
        dailyCheckinTime: '21:00',
        recoveryReason: 'Ingin menjadi versi terbaik untuk keluarga.',
      );

      await tester.pumpWidget(
        buildTestableWidget(ProfileHeaderCard(user: user)),
      );

      expect(find.text('Profil Kamu'), findsOneWidget);
      expect(find.text('Alex Parker'), findsOneWidget);
      expect(find.text('alex@example.com'), findsOneWidget);
      expect(
        find.text('Ingin menjadi versi terbaik untuk keluarga.'),
        findsOneWidget,
      );
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('ProfileSettingCard Widget Tests', () {
    testWidgets('renders title, subtitle, icon, and responds to tap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ProfileSettingCard(
            icon: Icons.track_changes_rounded,
            title: 'Atur Ulang Goals Kamu',
            subtitle: 'Sesuaikan target pemulihan kamu',
            assetPath: 'assets/images/maskots/set-porn-free-day.png',
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      expect(find.text('Atur Ulang Goals Kamu'), findsOneWidget);
      expect(find.text('Sesuaikan target pemulihan kamu'), findsOneWidget);
      expect(find.byIcon(Icons.track_changes_rounded), findsOneWidget);

      await tester.tap(find.byType(ProfileSettingCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('ProfileSheetScaffold Widget Tests', () {
    testWidgets('renders modal header, body content, and handles onSave', (
      tester,
    ) async {
      bool saved = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ProfileSheetScaffold(
            title: 'Sheet Title',
            subtitle: 'Sheet Subtitle',
            asset: 'assets/images/maskots/set-checkin-time.png',
            buttonLabel: 'Simpan',
            bodyBuilder: (_) => const Text('Custom Body Content'),
            onSave: () async {
              saved = true;
            },
          ),
        ),
      );

      expect(find.text('Sheet Title'), findsOneWidget);
      expect(find.text('Sheet Subtitle'), findsOneWidget);
      expect(find.text('Custom Body Content'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);

      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(saved, isTrue);
    });
  });
}
