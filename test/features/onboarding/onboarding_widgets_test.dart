import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/onboarding/presentation/widgets/onboarding_button.dart';
import 'package:recova/features/onboarding/presentation/widgets/onboarding_option_tile.dart';
import 'package:recova/features/onboarding/presentation/widgets/onboarding_progress_bar.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(theme: AppTheme.lightTheme, home: Scaffold(body: child));
  }

  group('OnboardingProgressBar Tests', () {
    testWidgets('computes step ratio correctly from factory constructor', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          OnboardingProgressBar.step(currentStep: 3, totalSteps: 9),
        ),
      );

      final fractionalSizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionalSizedBox.widthFactor, closeTo(3 / 9, 0.001));
    });

    testWidgets('handles boundary values gracefully', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          OnboardingProgressBar.step(currentStep: 10, totalSteps: 9),
        ),
      );

      final fractionalSizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionalSizedBox.widthFactor, equals(1.0));
    });
  });

  group('OnboardingOptionTile Tests', () {
    testWidgets('renders option title and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          OnboardingOptionTile(
            text: '13 sampai 16 tahun',
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('13 sampai 16 tahun'), findsOneWidget);
      await tester.tap(find.byType(OnboardingOptionTile));
      expect(tapped, isTrue);
    });

    testWidgets('renders selected visual state with primary color border', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          OnboardingOptionTile(
            text: 'Selected option',
            isSelected: true,
            onTap: () {},
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.width, equals(2.0));
    });
  });

  group('OnboardingButton Tests', () {
    testWidgets('renders button text and triggers onPressed when enabled', (
      tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          OnboardingButton(
            text: 'Continue',
            isEnabled: true,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('disables button and ignores tap when isEnabled is false', (
      tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          OnboardingButton(
            text: 'Continue',
            isEnabled: false,
            onPressed: () => pressed = true,
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isFalse);
    });
  });
}
