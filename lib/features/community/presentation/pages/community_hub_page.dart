import 'package:flutter/material.dart';
import 'package:recova/features/coach/presentation/pages/coach_page.dart';
import 'package:recova/features/community/presentation/pages/community_page.dart';
import 'package:recova/features/community/presentation/widgets/community_hero_banner.dart';
import 'package:recova/features/community/presentation/widgets/community_hub_menu_card.dart';
import 'package:recova/features/notifications/presentation/pages/notification_page.dart';

class CommunityHubPage extends StatelessWidget {
  const CommunityHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 64,
                      height: 64,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationPage(),
                          ),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const CommunityHeroBanner(),
              const SizedBox(height: 18),
              CommunityHubMenuCard(
                title: 'Chat Dengan Billy',
                subtitle:
                    'Billy merupakan AI companion yang akan menjawab semua keresahan kamu.',
                assetPath: 'assets/images/home/billy.png',
                imageWidth: 70,
                imageHeight: 70,
                imageOffset: const Offset(-5, 0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoachPage()),
                  );
                },
              ),
              const SizedBox(height: 14),
              CommunityHubMenuCard(
                title: 'Temukan Komunitas',
                subtitle: 'Temukan teman seperjuangan kamu di komunitas.',
                assetPath: 'assets/images/home/community.png',
                imageWidth: 70,
                imageHeight: 70,
                imageOffset: const Offset(0, 0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CommunityPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
