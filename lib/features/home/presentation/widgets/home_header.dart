import 'package:flutter/material.dart';
import 'package:recova/features/notifications/presentation/pages/notification_page.dart';

class HomeHeader extends StatelessWidget {
  final String nickname;
  final VoidCallback? onNotificationTap;

  const HomeHeader({super.key, required this.nickname, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
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
                  onNotificationTap ??
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationPage()),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Halo, $nickname!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Apapun usahamu hari ini, kami bangga kepadamu',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
