import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/features/community/presentation/widgets/community_filter_chips.dart';
import 'package:recova/features/community/presentation/widgets/community_hero_banner.dart';
import 'package:recova/features/community/presentation/widgets/community_hub_menu_card.dart';
import 'package:recova/features/community/presentation/widgets/community_post_card.dart';
import 'package:recova/models/post_model.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('CommunityFilterChips Widget Tests', () {
    testWidgets('renders all filter options and responds to tap', (
      tester,
    ) async {
      String selected = 'Nasihat';

      await tester.pumpWidget(
        buildTestableWidget(
          CommunityFilterChips(
            filters: const ['Nasihat', 'Bantuan', 'Motivasi'],
            selectedFilter: selected,
            onFilterSelected: (val) {
              selected = val;
            },
          ),
        ),
      );

      expect(find.text('Nasihat'), findsOneWidget);
      expect(find.text('Bantuan'), findsOneWidget);
      expect(find.text('Motivasi'), findsOneWidget);

      await tester.tap(find.text('Bantuan'));
      await tester.pumpAndSettle();

      expect(selected, equals('Bantuan'));
    });
  });

  group('CommunityHubMenuCard Widget Tests', () {
    testWidgets('renders title, subtitle, and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          CommunityHubMenuCard(
            title: 'Chat Dengan Billy',
            subtitle: 'AI companion yang ramah',
            assetPath: 'assets/images/home/billy.png',
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      expect(find.text('Chat Dengan Billy'), findsOneWidget);
      expect(find.text('AI companion yang ramah'), findsOneWidget);

      await tester.tap(find.byType(CommunityHubMenuCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('CommunityHeroBanner Widget Tests', () {
    testWidgets('renders hero banner title and description', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const CommunityHeroBanner()));

      expect(find.text('Kamu tidak berjuang sendirian'), findsOneWidget);
    });
  });

  group('CommunityPostCard Widget Tests', () {
    final testPost = Post(
      id: 'post_100',
      title: '14 Hari Bersih',
      content: 'Hari ini berhasil bertahan 14 hari tanpa relaps!',
      category: 'nasihat',
      userId: 'user_1',
      username: 'Budi Santoso',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 5,
      isLiked: false,
      commentCount: 3,
      userStreak: 14,
    );

    testWidgets('renders post details, masked username, and action counts', (
      tester,
    ) async {
      bool liked = false;
      bool commentsOpened = false;

      await tester.pumpWidget(
        buildTestableWidget(
          CommunityPostCard(
            post: testPost,
            onLike: () {
              liked = true;
            },
            onComments: () {
              commentsOpened = true;
            },
          ),
        ),
      );

      expect(
        find.text('Hari ini berhasil bertahan 14 hari tanpa relaps!'),
        findsOneWidget,
      );
      expect(find.text('Bud*****'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      expect(liked, isTrue);

      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      await tester.pumpAndSettle();
      expect(commentsOpened, isTrue);
    });
  });
}
