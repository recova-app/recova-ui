import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/auth/presentation/pages/login_page.dart';
import 'package:recova/features/auth/presentation/pages/register_page.dart';

void main() {
  Widget buildTestablePage(Widget page) {
    return MaterialApp(theme: AppTheme.lightTheme, home: page);
  }

  group('LoginPage View Tests', () {
    testWidgets('renders all login form fields, labels, and action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestablePage(const LoginPage()));
      await tester.pumpAndSettle();

      expect(find.text('Masuk'), findsWidgets);
      expect(find.text('Email atau username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Belum punya akun? '), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
    });

    testWidgets('triggers form validation when submitted with empty fields', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestablePage(const LoginPage()));
      await tester.pumpAndSettle();

      // Find the submit button with text 'Masuk'
      final submitButton = find.widgetWithText(ElevatedButton, 'Masuk');
      expect(submitButton, findsOneWidget);

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Email atau username wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    testWidgets('toggles password visibility icon when pressed', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestablePage(const LoginPage()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  group('RegisterPage View Tests', () {
    testWidgets('renders all registration form fields and buttons', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestablePage(const RegisterPage()));
      await tester.pumpAndSettle();

      expect(find.text('Buat Akun'), findsOneWidget);
      expect(find.text('Alamat email'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Konfirmasi password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Daftar'), findsOneWidget);
      expect(find.text('Sudah punya akun? '), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
    });

    testWidgets('triggers validation for empty inputs', (tester) async {
      await tester.pumpWidget(buildTestablePage(const RegisterPage()));
      await tester.pumpAndSettle();

      final registerButton = find.widgetWithText(ElevatedButton, 'Daftar');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Username wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
      expect(find.text('Konfirmasi password wajib diisi'), findsOneWidget);
    });

    testWidgets('validates password mismatch and min length', (tester) async {
      await tester.pumpWidget(buildTestablePage(const RegisterPage()));
      await tester.pumpAndSettle();

      // Fill in valid email and username
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Alamat email'),
        'user@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'recova_warrior',
      );

      // Short password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '12345',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Konfirmasi password'),
        'different_pass',
      );

      final registerButton = find.widgetWithText(ElevatedButton, 'Daftar');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 8 karakter'), findsOneWidget);
      expect(find.text('Konfirmasi password tidak cocok'), findsOneWidget);
    });
  });
}
