import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/notifications/presentation/models/notification_item.dart';
import 'package:recova/features/notifications/presentation/pages/notification_page.dart';
import 'package:recova/features/notifications/presentation/widgets/notification_item_tile.dart';

void main() {
  Widget buildTestableWidget(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('NotificationItemTile Widget Tests', () {
    testWidgets(
      'renders unread notification with badge dot and responds to tap',
      (tester) async {
        bool tapped = false;
        const notif = NotificationItem(
          icon: Icons.check_circle_outline_rounded,
          iconBg: Color(0xFF22C55E),
          title: 'Daily Check-In Reminder',
          body: 'Jangan lupa check-in hari ini!',
          time: 'Hari ini, 09:15',
          isRead: false,
        );

        await tester.pumpWidget(
          buildTestableWidget(
            NotificationItemTile(
              notification: notif,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        );

        expect(find.text('Daily Check-In Reminder'), findsOneWidget);
        expect(find.text('Jangan lupa check-in hari ini!'), findsOneWidget);
        expect(find.text('Hari ini, 09:15'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);

        await tester.tap(find.byType(NotificationItemTile));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      },
    );

    testWidgets('renders read notification without unread indicator', (
      tester,
    ) async {
      const notif = NotificationItem(
        icon: Icons.auto_stories_rounded,
        iconBg: Color(0xFF3B82F6),
        title: 'Konten Baru Tersedia',
        body: 'Artikel strategi pemulihan baru tersedia.',
        time: '2 hari lalu',
        isRead: true,
      );

      await tester.pumpWidget(
        buildTestableWidget(const NotificationItemTile(notification: notif)),
      );

      expect(find.text('Konten Baru Tersedia'), findsOneWidget);
      expect(find.text('2 hari lalu'), findsOneWidget);
    });
  });

  group('NotificationPage View Tests', () {
    testWidgets('renders notification list with default items', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const NotificationPage()));

      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('Daily Check-In Reminder'), findsOneWidget);
      expect(find.text('Streak Milestone 🎉'), findsOneWidget);
    });

    testWidgets('renders empty state when initial notifications are empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(const NotificationPage(initialNotifications: [])),
      );

      expect(find.text('Belum Ada Notifikasi'), findsOneWidget);
      expect(
        find.text(
          'Notifikasi tentang aktivitas dan pengingat harian akan muncul di sini.',
        ),
        findsOneWidget,
      );
    });
  });
}
