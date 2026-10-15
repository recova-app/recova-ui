import 'package:flutter/material.dart';
import 'package:recova/pages/notification_page.dart';

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
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 64,
                height: 64,
              ),
            ),
            GestureDetector(
              onTap:
                  onNotificationTap ??
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationPage()),
                  ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Halo, $nickname!',
          style: TextStyle(
            fontSize: 38 * 0.8,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Apapun usahamu hari ini, kami bangga kepadamu',
          style: TextStyle(
            fontSize: 30 * 0.42,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
