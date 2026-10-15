import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/core/ui/app_dialog.dart';
import 'package:recova/core/ui/app_toast.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(theme: AppTheme.lightTheme, home: Scaffold(body: child));
  }

  group('AppToast Utility Tests', () {
    testWidgets('showSuccess displays floating snackbar with check icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed:
                      () => AppToast.showSuccess(context, 'Check-in berhasil!'),
                  child: const Text('Show Success'),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      expect(find.text('Check-in berhasil!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('showError displays floating snackbar with error icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed:
                      () => AppToast.showError(context, 'Gagal terhubung'),
                  child: const Text('Show Error'),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.text('Gagal terhubung'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('showWarning displays floating snackbar with warning icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed:
                      () => AppToast.showWarning(context, 'Pilih mood kamu'),
                  child: const Text('Show Warning'),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Show Warning'));
      await tester.pump();

      expect(find.text('Pilih mood kamu'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('showInfo displays floating snackbar with info icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed:
                      () => AppToast.showInfo(context, 'Pengingat dimatikan'),
                  child: const Text('Show Info'),
                ),
          ),
        ),
      );

      await tester.tap(find.text('Show Info'));
      await tester.pump();

      expect(find.text('Pengingat dimatikan'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });
  });

  group('AppDialogShell Widget Tests', () {
    testWidgets('renders dialog title, subtitle, mascot, and dismiss button', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppDialogShell(
            title: 'Tantangan Hari Ini',
            subtitle: 'Lakukan peregangan 5 menit',
            mascotAssetPath: 'assets/images/maskots/activity.png',
            child: Text('Konten dialog pengujian'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tantangan Hari Ini'), findsOneWidget);
      expect(find.text('Lakukan peregangan 5 menit'), findsOneWidget);
      expect(find.text('Konten dialog pengujian'), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);
    });
  });
}
