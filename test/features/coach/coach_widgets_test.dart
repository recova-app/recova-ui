import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/coach/presentation/models/coach_chat_message.dart';
import 'package:recova/features/coach/presentation/models/coach_persona.dart';
import 'package:recova/features/coach/presentation/widgets/coach_chat_bubble.dart';
import 'package:recova/features/coach/presentation/widgets/coach_chat_input_bar.dart';
import 'package:recova/features/coach/presentation/widgets/coach_persona_selector.dart';

void main() {
  Widget buildTestableWidget(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('CoachPersona Model and Theming Tests', () {
    testWidgets('resolves theme-aware colors from RecoveryTheme', (
      tester,
    ) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        buildTestableWidget(
          Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
          theme: AppTheme.lightTheme,
        ),
      );

      final supportive = CoachPersona.defaultPersonas.firstWhere(
        (p) => p.key == 'supportive',
      );
      final friendly = CoachPersona.defaultPersonas.firstWhere(
        (p) => p.key == 'friendly',
      );
      final direct = CoachPersona.defaultPersonas.firstWhere(
        (p) => p.key == 'direct',
      );

      expect(
        supportive.backgroundColor(capturedContext),
        const Color(0xFFE8F5E9),
      );
      expect(
        friendly.backgroundColor(capturedContext),
        const Color(0xFFE0F2F1),
      );
      expect(direct.backgroundColor(capturedContext), const Color(0xFFFFF3E0));
    });
  });

  group('CoachChatBubble Widget Tests', () {
    testWidgets('renders user message bubble with correct text and alignment', (
      tester,
    ) async {
      final msg = CoachChatMessage(
        text: 'Aku butuh motivasi hari ini',
        isAI: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          CoachChatBubble(
            message: msg,
            avatarPath: 'assets/images/home/billy.png',
            personaTitle: 'Billy',
          ),
        ),
      );

      expect(find.text('Aku butuh motivasi hari ini'), findsOneWidget);
      expect(find.text('JUST NOW'), findsOneWidget);
    });

    testWidgets('renders AI markdown message with persona header and avatar', (
      tester,
    ) async {
      final msg = CoachChatMessage(
        text: '**Semangat!** Kamu sudah melangkah sejauh ini.',
        isAI: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        personaKey: 'supportive',
      );

      await tester.pumpWidget(
        buildTestableWidget(
          CoachChatBubble(
            message: msg,
            avatarPath: 'assets/images/home/supportiveBilly.png',
            personaTitle: 'Supportive Billy',
          ),
        ),
      );

      expect(find.text('Supportive Billy'), findsOneWidget);
      expect(find.textContaining('Semangat!'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('CoachChatInputBar Widget Tests', () {
    testWidgets('renders input bar, handles text typing and send action', (
      tester,
    ) async {
      final controller = TextEditingController();
      bool sent = false;

      await tester.pumpWidget(
        buildTestableWidget(
          CoachChatInputBar(
            controller: controller,
            isSending: false,
            onSend: () {
              sent = true;
            },
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Halo Billy');
      expect(controller.text, 'Halo Billy');

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(sent, isTrue);
    });

    testWidgets('shows loading indicator and disables field when sending', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestableWidget(
          CoachChatInputBar(
            controller: controller,
            isSending: true,
            onSend: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });
  });

  group('CoachPersonaSelector Widget Tests', () {
    testWidgets('toggles persona options and fires selection callback', (
      tester,
    ) async {
      bool toggled = false;
      CoachPersona? selected;
      final personas = CoachPersona.defaultPersonas;

      await tester.pumpWidget(
        buildTestableWidget(
          CoachPersonaSelector(
            selectedPersona: personas[0],
            personas: personas,
            isDropdownOpen: true,
            onToggleDropdown: () {
              toggled = true;
            },
            onSelectPersona: (p) {
              selected = p;
            },
          ),
        ),
      );

      expect(find.text('Supportive Billy'), findsOneWidget);
      expect(find.text('Friendly Billy'), findsOneWidget);
      expect(find.text('Direct Billy'), findsOneWidget);

      await tester.tap(find.text('Friendly Billy'));
      await tester.pumpAndSettle();

      expect(selected?.key, 'friendly');

      await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
      await tester.pumpAndSettle();

      expect(toggled, isTrue);
    });
  });
}
