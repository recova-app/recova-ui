import 'package:equatable/equatable.dart';

/// Centralized application configuration.
///
/// Reads environment variables from compile-time `--dart-define` constants with
/// sensible production defaults.
class AppConfig extends Equatable {
  const AppConfig({
    this.apiBaseUrl = configuredApiBaseUrl,
    this.environment = configuredEnvironment,
    this.connectTimeout = defaultConnectTimeout,
    this.receiveTimeout = defaultReceiveTimeout,
  });

  /// Default production API v1 base URL.
  static const String defaultApiBaseUrl =
      'https://recova.salmanabdurrahman.my.id/api/v1';

  /// Default production root base URL (without /api/v1).
  static const String defaultRootBaseUrl =
      'https://recova.salmanabdurrahman.my.id';

  /// Default runtime environment.
  static const String defaultEnvironment = 'production';

  /// Compile-time constant for API base URL via `--dart-define=API_BASE_URL=...`.
  static const String configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );

  /// Compile-time constant for environment via `--dart-define=APP_ENV=...`.
  static const String configuredEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: defaultEnvironment,
  );

  static const Duration defaultConnectTimeout = Duration(seconds: 15);
  static const Duration defaultReceiveTimeout = Duration(seconds: 30);

  final String apiBaseUrl;
  final String environment;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  /// Root host base URL without `/api/v1` path suffix.
  String get rootBaseUrl => deriveRootBaseUrl(apiBaseUrl);

  /// API base URL normalized with `/api/v1` path suffix.
  String get v1BaseUrl => deriveV1BaseUrl(apiBaseUrl);

  bool get isProduction => environment == 'production';
  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';

  /// Global current configuration instance.
  static AppConfig current = const AppConfig();

  /// Normalized v1 URL helper for static callers.
  static String get v1Url => current.v1BaseUrl;

  /// Normalized root URL helper for static callers.
  static String get rootUrl => current.rootBaseUrl;

  /// Derives root base URL by stripping trailing `/api/v1` and `/`.
  static String deriveRootBaseUrl(String url) {
    var clean = url.trim();
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    if (clean.endsWith('/api/v1')) {
      return clean.substring(0, clean.length - '/api/v1'.length);
    }
    return clean;
  }

  /// Derives v1 base URL by ensuring trailing `/api/v1` without double slashes.
  static String deriveV1BaseUrl(String url) {
    var clean = url.trim();
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    if (clean.endsWith('/api/v1')) {
      return clean;
    }
    return '$clean/api/v1';
  }

  @override
  List<Object?> get props => [
    apiBaseUrl,
    environment,
    connectTimeout,
    receiveTimeout,
  ];
}
