import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Immutable state holding the active [ThemeMode].
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.light});

  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }

  @override
  List<Object?> get props => [themeMode];
}

/// Cubit managing application theme mode (light, dark, system)
/// with encrypted local persistence via [FlutterSecureStorage].
class ThemeCubit extends Cubit<ThemeState> {
  final FlutterSecureStorage _storage;

  /// Storage key for persisted theme preference.
  static const String themeStorageKey = 'app_theme_mode';

  ThemeCubit({
    FlutterSecureStorage? storage,
    ThemeMode initialMode = ThemeMode.light,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       super(ThemeState(themeMode: initialMode));

  /// Reads stored theme preference from local secure storage.
  Future<void> loadTheme() async {
    try {
      final rawMode = await _storage.read(key: themeStorageKey);
      if (rawMode == null || rawMode.isEmpty) return;

      final mode = parseThemeMode(rawMode);
      emit(state.copyWith(themeMode: mode));
    } catch (_) {
      // Gracefully maintain current mode if storage access fails
    }
  }

  /// Sets and persists a specific [ThemeMode].
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    try {
      await _storage.write(
        key: themeStorageKey,
        value: serializeThemeMode(mode),
      );
    } catch (_) {
      // Gracefully continue if storage write fails
    }
  }

  /// Toggles between light and dark modes.
  Future<void> toggleTheme({
    Brightness platformBrightness = Brightness.light,
  }) async {
    final currentIsDark =
        state.themeMode == ThemeMode.dark ||
        (state.themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);
    final nextMode = currentIsDark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }

  /// Parses string representation into [ThemeMode].
  static ThemeMode parseThemeMode(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Serializes [ThemeMode] into durable storage string.
  static String serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
