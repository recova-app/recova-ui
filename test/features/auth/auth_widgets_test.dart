import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/auth/presentation/widgets/auth_button.dart';
import 'package:recova/features/auth/presentation/widgets/auth_header.dart';
import 'package:recova/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:recova/features/auth/presentation/widgets/auth_validation_banner.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(theme: AppTheme.lightTheme, home: Scaffold(body: child));
  }

  group('AuthTextField Widget Tests', () {
    testWidgets('renders hint text and prefix icon', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestableWidget(
          AuthTextField(
            controller: controller,
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
          ),
        ),
      );

      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('accepts text input and updates controller', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestableWidget(
          AuthTextField(
            controller: controller,
            hint: 'Username',
            prefixIcon: Icons.person,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'recovery_user');
      expect(controller.text, equals('recovery_user'));
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestableWidget(
          AuthTextField(
            controller: controller,
            hint: 'Password',
            prefixIcon: Icons.lock,
            obscureText: true,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('renders suffix icon when provided', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestableWidget(
          AuthTextField(
            controller: controller,
            hint: 'Password',
            prefixIcon: Icons.lock,
            suffixIcon: const Icon(Icons.visibility),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  group('AuthButton Widget Tests', () {
    testWidgets('renders label and invokes onPressed when tapped', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AuthButton(text: 'Submit Login', onPressed: () => tapped = true),
        ),
      );

      expect(find.text('Submit Login'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets(
      'shows CircularProgressIndicator and ignores tap when loading',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          buildTestableWidget(
            AuthButton(
              text: 'Submit Login',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Submit Login'), findsNothing);

        await tester.tap(find.byType(ElevatedButton));
        expect(tapped, isFalse);
      },
    );
  });

  group('AuthValidationBanner Widget Tests', () {
    testWidgets('renders error message and icon', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AuthValidationBanner(message: 'Invalid credentials provided'),
        ),
      );

      expect(find.text('Invalid credentials provided'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('invokes onDismiss callback when close icon tapped', (
      tester,
    ) async {
      bool dismissed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AuthValidationBanner(
            message: 'Dismissable alert',
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(dismissed, isTrue);
    });

    testWidgets('showErrorSnackBar helper displays floating snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AuthValidationBanner.showErrorSnackBar(
                    context,
                    'Network failure',
                  );
                },
                child: const Text('Show SnackBar'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show SnackBar'));
      await tester.pump(); // Start animation

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Network failure'), findsOneWidget);
    });
  });

  group('AuthHeader Widget Tests', () {
    testWidgets('renders title and subtitle correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AuthHeader(
            title: 'Welcome Back',
            subtitle: 'Secure recovery journey',
          ),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Secure recovery journey'), findsOneWidget);
    });
  });
}
