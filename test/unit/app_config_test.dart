import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/config/app_config.dart';

void main() {
  group('AppConfig Centralized Configuration', () {
    test('default configuration provides production URLs and values', () {
      const config = AppConfig();

      expect(
        config.apiBaseUrl,
        equals('https://recova.salmanabdurrahman.my.id/api/v1'),
      );
      expect(
        config.rootBaseUrl,
        equals('https://recova.salmanabdurrahman.my.id'),
      );
      expect(
        config.v1BaseUrl,
        equals('https://recova.salmanabdurrahman.my.id/api/v1'),
      );
      expect(config.environment, equals('production'));
      expect(config.isProduction, isTrue);
      expect(config.isDevelopment, isFalse);
      expect(config.isStaging, isFalse);
      expect(config.connectTimeout, equals(const Duration(seconds: 15)));
      expect(config.receiveTimeout, equals(const Duration(seconds: 30)));
    });

    test('static helpers reflect current configuration instance', () {
      expect(
        AppConfig.v1Url,
        equals('https://recova.salmanabdurrahman.my.id/api/v1'),
      );
      expect(
        AppConfig.rootUrl,
        equals('https://recova.salmanabdurrahman.my.id'),
      );
    });

    group('URL normalization and derivation helpers', () {
      test('deriveRootBaseUrl strips /api/v1 and trailing slashes', () {
        expect(
          AppConfig.deriveRootBaseUrl('https://example.com/api/v1'),
          equals('https://example.com'),
        );
        expect(
          AppConfig.deriveRootBaseUrl('https://example.com/api/v1/'),
          equals('https://example.com'),
        );
        expect(
          AppConfig.deriveRootBaseUrl('https://example.com///'),
          equals('https://example.com'),
        );
        expect(
          AppConfig.deriveRootBaseUrl('http://10.0.2.2:8080/api/v1'),
          equals('http://10.0.2.2:8080'),
        );
        expect(
          AppConfig.deriveRootBaseUrl('http://10.0.2.2:8080'),
          equals('http://10.0.2.2:8080'),
        );
      });

      test('deriveV1BaseUrl ensures single /api/v1 suffix', () {
        expect(
          AppConfig.deriveV1BaseUrl('https://example.com'),
          equals('https://example.com/api/v1'),
        );
        expect(
          AppConfig.deriveV1BaseUrl('https://example.com/'),
          equals('https://example.com/api/v1'),
        );
        expect(
          AppConfig.deriveV1BaseUrl('https://example.com/api/v1'),
          equals('https://example.com/api/v1'),
        );
        expect(
          AppConfig.deriveV1BaseUrl('https://example.com/api/v1/'),
          equals('https://example.com/api/v1'),
        );
        expect(
          AppConfig.deriveV1BaseUrl('http://localhost:3000///'),
          equals('http://localhost:3000/api/v1'),
        );
      });
    });

    test('custom instance overrides environment and timeouts', () {
      final custom = AppConfig(
        apiBaseUrl: 'http://10.0.2.2:8080',
        environment: 'development',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      );

      expect(custom.apiBaseUrl, equals('http://10.0.2.2:8080'));
      expect(custom.rootBaseUrl, equals('http://10.0.2.2:8080'));
      expect(custom.v1BaseUrl, equals('http://10.0.2.2:8080/api/v1'));
      expect(custom.environment, equals('development'));
      expect(custom.isDevelopment, isTrue);
      expect(custom.isProduction, isFalse);
      expect(custom.isStaging, isFalse);
      expect(custom.connectTimeout, equals(const Duration(seconds: 5)));
      expect(custom.receiveTimeout, equals(const Duration(seconds: 10)));
    });

    test('instances with equal properties are value-equal', () {
      final a = AppConfig(
        apiBaseUrl: 'http://test.local/api/v1',
        environment: 'staging',
      );
      final b = AppConfig(
        apiBaseUrl: 'http://test.local/api/v1',
        environment: 'staging',
      );

      expect(a, equals(b));
      expect(a.isStaging, isTrue);
    });
  });
}
