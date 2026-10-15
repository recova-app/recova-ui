import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/education/presentation/widgets/article_card.dart';
import 'package:recova/features/education/presentation/widgets/article_markdown_view.dart';
import 'package:recova/features/education/presentation/widgets/education_feature_card.dart';
import 'package:recova/features/education/presentation/widgets/education_quote_card.dart';
import 'package:recova/features/education/presentation/widgets/education_video_card.dart';
import 'package:recova/models/education_model.dart';

void main() {
  Widget buildTestableWidget(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('EducationQuoteCard Widget Tests', () {
    testWidgets('renders quote, author, and mascot container', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const EducationQuoteCard(
            title: 'Quote Hari Ini',
            quote: 'Perubahan kecil membawa hasil besar.',
            author: '— James Clear',
          ),
        ),
      );

      expect(find.text('Quote Hari Ini'), findsOneWidget);
      expect(find.text('Perubahan kecil membawa hasil besar.'), findsOneWidget);
      expect(find.text('— James Clear'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('EducationFeatureCard Widget Tests', () {
    testWidgets('renders title, subtitle, and responds to click events', (
      tester,
    ) async {
      bool clicked = false;

      await tester.pumpWidget(
        buildTestableWidget(
          EducationFeatureCard(
            title: 'Tips & Strategi Pemulihan',
            subtitle: 'Tips praktis mengatasi dorongan kambuh',
            assetPath: 'assets/images/maskots/pemulihan.png',
            arrow: true,
            onTap: () {
              clicked = true;
            },
          ),
        ),
      );

      expect(find.text('Tips & Strategi Pemulihan'), findsOneWidget);
      expect(
        find.text('Tips praktis mengatasi dorongan kambuh'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.byType(EducationFeatureCard));
      await tester.pumpAndSettle();

      expect(clicked, isTrue);
    });
  });

  group('ArticleCard Widget Tests', () {
    testWidgets('renders title, subtitle preview, and triggers onTap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ArticleCard(
            title: 'Memahami Siklus Relapse',
            subtitle: 'Penjelasan psikologis mengenai pemicu kambuh.',
            tag: 'Pemulihan',
            readTime: '4 min read',
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      expect(find.text('Memahami Siklus Relapse'), findsOneWidget);
      expect(
        find.text('Penjelasan psikologis mengenai pemicu kambuh.'),
        findsOneWidget,
      );
      expect(find.text('Baca Lebih Lanjut >'), findsOneWidget);

      await tester.tap(find.byType(ArticleCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('ArticleMarkdownView Widget Tests', () {
    testWidgets('renders formatted markdown headings and paragraphs', (
      tester,
    ) async {
      const markdown = '# Judul Edukasi\n\nParagraf penjelasan pemulihan.';

      await tester.pumpWidget(
        buildTestableWidget(const ArticleMarkdownView(data: markdown)),
      );

      expect(find.textContaining('Judul Edukasi'), findsOneWidget);
      expect(
        find.textContaining('Paragraf penjelasan pemulihan.'),
        findsOneWidget,
      );
    });
  });

  group('EducationVideoCard Widget Tests', () {
    testWidgets('renders video card with title and network placeholder', (
      tester,
    ) async {
      final content = EducationContent(
        id: '1',
        title: 'Video Strategi Mengatasi Urge',
        description: 'Panduan visual mengatasi dorongan',
        url: 'https://example.com/video',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        category: 'Strategi',
        type: 'video',
      );

      await tester.pumpWidget(
        buildTestableWidget(EducationVideoCard(content: content)),
      );

      expect(find.text('Video Strategi Mengatasi Urge'), findsOneWidget);
      expect(find.byType(EducationVideoCard), findsOneWidget);
    });
  });
}
