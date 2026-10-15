import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recova/core/theme/theme_cubit.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('ThemeCubit State and Persistence', () {
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
    });

    test('initial state defaults to light ThemeMode', () {
      final cubit = ThemeCubit(storage: mockStorage);
      expect(cubit.state.themeMode, equals(ThemeMode.light));
      expect(cubit.state.isDarkMode, isFalse);
    });

    test('initial state respects custom initial ThemeMode', () {
      final cubit = ThemeCubit(
        storage: mockStorage,
        initialMode: ThemeMode.dark,
      );
      expect(cubit.state.themeMode, equals(ThemeMode.dark));
      expect(cubit.state.isDarkMode, isTrue);
    });

    test('loadTheme emits light theme when storage returns light', () async {
      when(
        () => mockStorage.read(key: ThemeCubit.themeStorageKey),
      ).thenAnswer((_) async => 'light');

      final cubit = ThemeCubit(storage: mockStorage);
      await cubit.loadTheme();

      expect(cubit.state.themeMode, equals(ThemeMode.light));
      expect(cubit.state.isDarkMode, isFalse);
      verify(() => mockStorage.read(key: ThemeCubit.themeStorageKey)).called(1);
    });

    test('loadTheme emits dark theme when storage returns dark', () async {
      when(
        () => mockStorage.read(key: ThemeCubit.themeStorageKey),
      ).thenAnswer((_) async => 'dark');

      final cubit = ThemeCubit(storage: mockStorage);
      await cubit.loadTheme();

      expect(cubit.state.themeMode, equals(ThemeMode.dark));
      expect(cubit.state.isDarkMode, isTrue);
    });

    test('loadTheme emits system theme when storage returns system', () async {
      when(
        () => mockStorage.read(key: ThemeCubit.themeStorageKey),
      ).thenAnswer((_) async => 'system');

      final cubit = ThemeCubit(
        storage: mockStorage,
        initialMode: ThemeMode.dark,
      );
      await cubit.loadTheme();

      expect(cubit.state.themeMode, equals(ThemeMode.system));
    });

    test(
      'loadTheme preserves current mode when storage returns null',
      () async {
        when(
          () => mockStorage.read(key: ThemeCubit.themeStorageKey),
        ).thenAnswer((_) async => null);

        final cubit = ThemeCubit(
          storage: mockStorage,
          initialMode: ThemeMode.light,
        );
        await cubit.loadTheme();

        expect(cubit.state.themeMode, equals(ThemeMode.light));
      },
    );

    test('loadTheme gracefully handles storage read exceptions', () async {
      when(
        () => mockStorage.read(key: ThemeCubit.themeStorageKey),
      ).thenThrow(Exception('Secure storage read failure'));

      final cubit = ThemeCubit(storage: mockStorage);
      await cubit.loadTheme();

      expect(cubit.state.themeMode, equals(ThemeMode.light));
    });

    test('setThemeMode emits updated mode and writes to storage', () async {
      when(
        () => mockStorage.write(
          key: ThemeCubit.themeStorageKey,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final cubit = ThemeCubit(storage: mockStorage);
      await cubit.setThemeMode(ThemeMode.dark);

      expect(cubit.state.themeMode, equals(ThemeMode.dark));
      verify(
        () => mockStorage.write(key: ThemeCubit.themeStorageKey, value: 'dark'),
      ).called(1);
    });

    test('setThemeMode handles storage write exceptions gracefully', () async {
      when(
        () => mockStorage.write(
          key: ThemeCubit.themeStorageKey,
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('Disk IO error'));

      final cubit = ThemeCubit(storage: mockStorage);
      await cubit.setThemeMode(ThemeMode.light);

      expect(cubit.state.themeMode, equals(ThemeMode.light));
    });

    test('toggleTheme switches from light to dark', () async {
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
      await cubit.toggleTheme();

      expect(cubit.state.themeMode, equals(ThemeMode.dark));
      verify(
        () => mockStorage.write(key: ThemeCubit.themeStorageKey, value: 'dark'),
      ).called(1);
    });

    test('toggleTheme switches from dark to light', () async {
      when(
        () => mockStorage.write(
          key: ThemeCubit.themeStorageKey,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final cubit = ThemeCubit(
        storage: mockStorage,
        initialMode: ThemeMode.dark,
      );
      await cubit.toggleTheme();

      expect(cubit.state.themeMode, equals(ThemeMode.light));
      verify(
        () =>
            mockStorage.write(key: ThemeCubit.themeStorageKey, value: 'light'),
      ).called(1);
    });

    test(
      'toggleTheme switches to dark when in system mode on light platform',
      () async {
        when(
          () => mockStorage.write(
            key: ThemeCubit.themeStorageKey,
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        final cubit = ThemeCubit(
          storage: mockStorage,
          initialMode: ThemeMode.system,
        );
        await cubit.toggleTheme(platformBrightness: Brightness.light);

        expect(cubit.state.themeMode, equals(ThemeMode.dark));
        verify(
          () =>
              mockStorage.write(key: ThemeCubit.themeStorageKey, value: 'dark'),
        ).called(1);
      },
    );

    test(
      'toggleTheme switches to light when in system mode on dark platform',
      () async {
        when(
          () => mockStorage.write(
            key: ThemeCubit.themeStorageKey,
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        final cubit = ThemeCubit(
          storage: mockStorage,
          initialMode: ThemeMode.system,
        );
        await cubit.toggleTheme(platformBrightness: Brightness.dark);

        expect(cubit.state.themeMode, equals(ThemeMode.light));
        verify(
          () => mockStorage.write(
            key: ThemeCubit.themeStorageKey,
            value: 'light',
          ),
        ).called(1);
      },
    );

    test(
      'parseThemeMode parses case-insensitively and falls back to system',
      () {
        expect(ThemeCubit.parseThemeMode('light'), equals(ThemeMode.light));
        expect(ThemeCubit.parseThemeMode('LIGHT'), equals(ThemeMode.light));
        expect(ThemeCubit.parseThemeMode('dark'), equals(ThemeMode.dark));
        expect(ThemeCubit.parseThemeMode('DARK'), equals(ThemeMode.dark));
        expect(ThemeCubit.parseThemeMode('system'), equals(ThemeMode.system));
        expect(ThemeCubit.parseThemeMode('unknown'), equals(ThemeMode.system));
        expect(ThemeCubit.parseThemeMode(''), equals(ThemeMode.system));
      },
    );

    test('serializeThemeMode returns canonical strings', () {
      expect(ThemeCubit.serializeThemeMode(ThemeMode.light), equals('light'));
      expect(ThemeCubit.serializeThemeMode(ThemeMode.dark), equals('dark'));
      expect(ThemeCubit.serializeThemeMode(ThemeMode.system), equals('system'));
    });

    test('ThemeState supports Equatable value equality', () {
      const state1 = ThemeState(themeMode: ThemeMode.light);
      const state2 = ThemeState(themeMode: ThemeMode.light);
      const state3 = ThemeState(themeMode: ThemeMode.dark);

      expect(state1, equals(state2));
      expect(state1 == state3, isFalse);
    });
  });
}
