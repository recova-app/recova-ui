import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/core/theme/app_colors.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/core/theme/theme_cubit.dart';
import 'package:recova/pages/theme_settings_page.dart';

class MockSecureStorageForTokens extends Mock implements FlutterSecureStorage {}

double _relativeLuminance(Color color) {
  double channel(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.red / 255.0) +
      0.7152 * channel(color.green / 255.0) +
      0.0722 * channel(color.blue / 255.0);
}

double _contrastRatio(Color c1, Color c2) {
  final l1 = _relativeLuminance(c1);
  final l2 = _relativeLuminance(c2);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('Standardized Material 3 Design Tokens and Color Schemes', () {
    test('light and dark ColorSchemes have correct brightness and tokens', () {
      final light = AppTheme.lightColorScheme;
      expect(light.brightness, equals(Brightness.light));
      expect(light.primary, equals(AppColors.primary));
      expect(light.secondary, equals(AppColors.secondary));
      expect(light.error, equals(AppColors.error));
      expect(light.surface, equals(AppColors.surfaceLight));

      final dark = AppTheme.darkColorScheme;
      expect(dark.brightness, equals(Brightness.dark));
      expect(dark.primary, equals(AppColors.primaryLight));
      expect(dark.secondary, equals(AppColors.secondaryLight));
      expect(dark.surface, equals(AppColors.surfaceDark));
    });

    test('contrast ratios satisfy WCAG AA requirements', () {
      // Primary text on light surface (> 4.5:1 required, 7:1 preferred)
      final lightTextContrast = _contrastRatio(
        AppColors.textPrimaryLight,
        AppColors.surfaceLight,
      );
      expect(
        lightTextContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Text primary on light surface must meet WCAG AA (>= 4.5:1)',
      );

      // Secondary text on light surface
      final lightSecContrast = _contrastRatio(
        AppColors.textSecondaryLight,
        AppColors.surfaceLight,
      );
      expect(
        lightSecContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Text secondary on light surface must meet WCAG AA',
      );

      // Primary text on dark surface
      final darkTextContrast = _contrastRatio(
        AppColors.textPrimaryDark,
        AppColors.surfaceDark,
      );
      expect(
        darkTextContrast,
        greaterThanOrEqualTo(4.5),
        reason: 'Text primary on dark surface must meet WCAG AA (>= 4.5:1)',
      );

      // Brand primary button text (white on brand primary) meets UI / large text contrast
      final buttonContrast = _contrastRatio(Colors.white, AppColors.primary);
      expect(
        buttonContrast,
        greaterThanOrEqualTo(3.0),
        reason: 'Button text contrast must meet WCAG AA UI standard (>= 3.0:1)',
      );
    });

    test('lightTheme and darkTheme register RecoveryTheme extension', () {
      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.useMaterial3, isTrue);
      expect(lightTheme.extension<RecoveryTheme>(), isNotNull);

      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.extension<RecoveryTheme>(), isNotNull);
    });

    test(
      'legacy static color aliases remain accessible for backward compatibility',
      () {
        expect(AppTheme.primary, equals(AppColors.primary));
        expect(AppTheme.secondary, equals(AppColors.secondary));
        expect(AppTheme.surface, equals(AppColors.surfaceLight));
        expect(AppTheme.textDark, equals(AppColors.textPrimaryLight));
        expect(AppTheme.success, equals(AppColors.success));
        expect(AppTheme.warning, equals(AppColors.warning));
        expect(AppTheme.error, equals(AppColors.error));
        expect(AppText.h1.fontSize, equals(32));
        expect(AppSpacing.medium, equals(16.0));
        expect(AppRadius.medium, equals(12.0));
      },
    );
  });

  group('RecoveryTheme ThemeExtension Implementation', () {
    test('light and dark presets define all custom recovery tokens', () {
      const light = RecoveryTheme.light;
      expect(light.streakGradient.colors.length, equals(2));
      expect(light.supportivePersonaColor, isNotNull);
      expect(light.friendlyPersonaColor, isNotNull);
      expect(light.directPersonaColor, isNotNull);
      expect(light.cleanStatusColor, equals(AppColors.success));
      expect(light.relapseStatusColor, equals(AppColors.error));
      expect(light.warningStatusColor, equals(AppColors.warning));

      const dark = RecoveryTheme.dark;
      expect(dark.streakGradient.colors.length, equals(2));
      expect(dark.supportivePersonaColor, isNotNull);
      expect(dark.friendlyPersonaColor, isNotNull);
      expect(dark.directPersonaColor, isNotNull);
      expect(dark.cleanStatusColor, isNotNull);
      expect(dark.relapseStatusColor, isNotNull);
    });

    test('copyWith creates clone with overridden properties', () {
      const original = RecoveryTheme.light;
      final modified = original.copyWith(
        cleanStatusColor: Colors.blue,
        directPersonaTextColor: Colors.purple,
      );

      expect(modified.cleanStatusColor, equals(Colors.blue));
      expect(modified.directPersonaTextColor, equals(Colors.purple));
      expect(modified.relapseStatusColor, equals(original.relapseStatusColor));
      expect(modified.streakGradient, equals(original.streakGradient));
    });

    test('lerp correctly interpolates between themes during animations', () {
      const start = RecoveryTheme.light;
      const end = RecoveryTheme.dark;

      // t = 0.0 returns exact start values
      final atZero = start.lerp(end, 0.0);
      expect(atZero.cleanStatusColor, equals(start.cleanStatusColor));
      expect(atZero.streakCardBackground, equals(start.streakCardBackground));

      // t = 1.0 returns exact end values
      final atOne = start.lerp(end, 1.0);
      expect(atOne.cleanStatusColor, equals(end.cleanStatusColor));
      expect(atOne.streakCardBackground, equals(end.streakCardBackground));

      // t = 0.5 returns interpolated midpoint
      final atHalf = start.lerp(end, 0.5);
      final expectedCleanMidpoint = Color.lerp(
        start.cleanStatusColor,
        end.cleanStatusColor,
        0.5,
      );
      expect(atHalf.cleanStatusColor, equals(expectedCleanMidpoint));

      // null or non-RecoveryTheme returns original without throwing
      final atNull = start.lerp(null, 0.5);
      expect(atNull.cleanStatusColor, equals(start.cleanStatusColor));
    });

    testWidgets(
      'RecoveryTheme.of and context.recoveryTheme resolve extension',
      (tester) async {
        late RecoveryTheme resolvedTheme;
        late RecoveryTheme contextTheme;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Builder(
              builder: (context) {
                resolvedTheme = RecoveryTheme.of(context);
                contextTheme = context.recoveryTheme;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(resolvedTheme.cleanStatusColor, equals(AppColors.success));
        expect(contextTheme.cleanStatusColor, equals(AppColors.success));
      },
    );

    testWidgets('ThemeSettingsPage toggles theme mode via ThemeCubit', (
      tester,
    ) async {
      final mockStorage = MockSecureStorageForTokens();
      when(
        () => mockStorage.write(
          key: ThemeCubit.themeStorageKey,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final cubit = ThemeCubit(
        storage: mockStorage,
        initialMode: ThemeMode.light,
      );

      await tester.pumpWidget(
        BlocProvider<ThemeCubit>.value(
          value: cubit,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const ThemeSettingsPage(),
          ),
        ),
      );

      expect(cubit.state.themeMode, equals(ThemeMode.light));

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(cubit.state.themeMode, equals(ThemeMode.dark));
    });
  });
}
