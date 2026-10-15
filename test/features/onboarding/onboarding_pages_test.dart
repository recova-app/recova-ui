import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/onboarding/presentation/pages/benefits_page.dart';
import 'package:recova/features/onboarding/presentation/pages/learning_1_page.dart';
import 'package:recova/features/onboarding/presentation/pages/learning_5_page.dart';
import 'package:recova/features/onboarding/presentation/pages/questions/question_1_page.dart';
import 'package:recova/features/onboarding/presentation/pages/results_page.dart';
import 'package:recova/features/onboarding/presentation/pages/set_name_page.dart';
import 'package:recova/features/onboarding/presentation/pages/set_porn_free_day_page.dart';
import 'package:recova/features/onboarding/presentation/pages/why_checkin_page.dart';
import 'package:recova/services/onboarding_state.dart';

void main() {
  setUp(() {
    OnboardingState().reset();
  });

  Widget buildTestableApp({
    required Widget home,
    Map<String, WidgetBuilder>? routes,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: home,
      routes: routes ?? {},
    );
  }

  group('Learning1 Page Tests', () {
    testWidgets('renders headline, illustration, and navigates on tap', (
      tester,
    ) async {
      bool navigated = false;

      await tester.pumpWidget(
        buildTestableApp(
          home: const Learning1(),
          routes: {
            '/learning-2': (context) {
              navigated = true;
              return const Scaffold(body: Text('Learning 2'));
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Mengapa Saya Menonton Begitu Banyak Pornografi?'),
        findsOneWidget,
      );
      expect(find.text('Selanjutnya'), findsOneWidget);

      await tester.tap(find.text('Selanjutnya'));
      await tester.pumpAndSettle();

      expect(navigated, isTrue);
    });
  });

  group('SetNamePage Tests', () {
    testWidgets(
      'enables submit button only when name is non-empty and stores nickname',
      (tester) async {
        bool navigated = false;

        await tester.pumpWidget(
          buildTestableApp(
            home: const SetNamePage(),
            routes: {
              '/question-1': (context) {
                navigated = true;
                return const Scaffold(body: Text('Question 1'));
              },
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Apa nama panggilan kamu?'), findsOneWidget);
        final buttonFinder = find.widgetWithText(ElevatedButton, 'Lanjutkan');
        final button = tester.widget<ElevatedButton>(buttonFinder);
        expect(button.onPressed, isNull);

        // Enter name
        await tester.enterText(find.byType(TextField), 'Alex');
        await tester.pumpAndSettle();

        final enabledButton = tester.widget<ElevatedButton>(buttonFinder);
        expect(enabledButton.onPressed, isNotNull);

        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();

        expect(OnboardingState().nickname, equals('Alex'));
        expect(navigated, isTrue);
      },
    );
  });

  group('Question1 Page Tests', () {
    testWidgets('selects option, records response into state, and navigates', (
      tester,
    ) async {
      bool navigated = false;

      await tester.pumpWidget(
        buildTestableApp(
          home: const Question1(),
          routes: {
            '/question-2': (context) {
              navigated = true;
              return const Scaffold(body: Text('Question 2'));
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pertanyaan 1'), findsOneWidget);
      expect(find.text('13 sampai 16 tahun'), findsOneWidget);

      // Select answer
      await tester.tap(find.text('13 sampai 16 tahun'));
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(
        OnboardingState()
            .answers['Diumur berapa kamu menonton pornografi untuk pertama kalinya?'],
        equals('13_to_16'),
      );
      expect(navigated, isTrue);
    });
  });

  group('SetPornFreeDayPage Tests', () {
    testWidgets(
      'renders recovery goals, selects goal, and navigates to result',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          buildTestableApp(
            home: const SetPornFreeDayPage(),
            routes: {
              '/know-your-why':
                  (context) => const Scaffold(body: Text('Know Your Why')),
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('14 hari'), findsOneWidget);
        expect(find.text('Rekomendasi'), findsOneWidget);
        expect(find.text('Targetkan'), findsOneWidget);

        // Select 30 hari
        await tester.tap(find.text('30 hari'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Targetkan'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();

        expect(OnboardingState().pornFreeGoal, equals(30));
      },
    );
  });

  group('BenefitsPage Tests', () {
    testWidgets('renders benefits list and navigates to homepage on continue', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool navigated = false;

      await tester.pumpWidget(
        buildTestableApp(
          home: const BenefitsPage(),
          routes: {
            '/homepage': (context) {
              navigated = true;
              return const Scaffold(body: Text('Homepage'));
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Keuntungan Berhenti'), findsOneWidget);
      expect(find.text('Peningkatan rasa percaya diri'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Selanjutnya'));
      await tester.pumpAndSettle();

      expect(navigated, isTrue);
    });
  });

  group('WhyCheckinPage Tests', () {
    testWidgets('renders checkin rationale and navigates to time setup', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool navigated = false;

      await tester.pumpWidget(
        buildTestableApp(
          home: const WhyCheckinPage(),
          routes: {
            '/set-checkin-time': (context) {
              navigated = true;
              return const Scaffold(body: Text('Set Time'));
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mengapa check-in harian penting?'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Saya mengerti'));
      await tester.pumpAndSettle();

      expect(navigated, isTrue);
    });
  });

  group('Learning5 Page Tests', () {
    testWidgets('renders recovery explanation and routes to set-name', (
      tester,
    ) async {
      bool navigated = false;

      await tester.pumpWidget(
        buildTestableApp(
          home: const Learning5(),
          routes: {
            '/set-name': (context) {
              navigated = true;
              return const Scaffold(body: Text('Set Name'));
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Wajar jika kamu merasa terjebak oleh pornografi. Tapi kamu tidak benar-benar terjebak.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Selanjutnya'));
      await tester.pumpAndSettle();

      expect(navigated, isTrue);
    });
  });

  group('ResultsPage Tests', () {
    testWidgets(
      'renders questionnaire analysis data and recovery theme tokens',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        bool navigated = false;

        final testAnalysisData = {
          'nickname': 'Jordan',
          'onboarding_analysis': {
            'level': 'Moderate',
            'title': 'Analisis Ketergantungan',
            'level_description':
                'Tingkat ketergantungan sedang teridentifikasi.',
            'pattern_analysis': 'Pemicu utama timbul saat stres tinggi.',
            'encouragement': 'Kamu berada di jalur pemulihan yang tepat!',
          },
        };

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                settings: RouteSettings(
                  name: '/results',
                  arguments: testAnalysisData,
                ),
                builder: (context) => const ResultsPage(),
              );
            },
            routes: {
              '/benefits': (context) {
                navigated = true;
                return const Scaffold(body: Text('Benefits'));
              },
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Analisis Ketergantungan'), findsOneWidget);
        expect(find.text('Moderate'), findsOneWidget);
        expect(find.text('Analisis Pola'), findsOneWidget);
        expect(
          find.text('Pemicu utama timbul saat stres tinggi.'),
          findsOneWidget,
        );
        expect(find.text('Semangat Untukmu , Jordan'), findsOneWidget);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Selanjutnya'));
        await tester.pumpAndSettle();

        expect(navigated, isTrue);
      },
    );
  });
}
