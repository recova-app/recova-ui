import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_colors.dart';
import '../models/notification_item.dart';
import '../widgets/notification_item_tile.dart';

/// Notification history page displaying user alerts, reminders, and milestones.
class NotificationPage extends StatelessWidget {
  final List<NotificationItem>? initialNotifications;

  const NotificationPage({super.key, this.initialNotifications});

  static List<NotificationItem> get defaultNotifications => [
    const NotificationItem(
      icon: Icons.check_circle_outline_rounded,
      iconBg: AppColors.success,
      title: 'Daily Check-In Reminder',
      body: 'Jangan lupa check-in hari ini untuk mempertahankan streak kamu!',
      time: 'Hari ini, 09:15',
      isRead: false,
    ),
    const NotificationItem(
      icon: Icons.local_fire_department_rounded,
      iconBg: AppColors.warning,
      title: 'Streak Milestone 🎉',
      body: 'Selamat! Kamu sudah mencapai 7 hari streak. Terus pertahankan!',
      time: 'Kemarin, 00:00',
      isRead: false,
    ),
    const NotificationItem(
      icon: Icons.auto_stories_rounded,
      iconBg: AppColors.info,
      title: 'Konten Baru Tersedia',
      body: 'Ada artikel baru tentang strategi pemulihan. Yuk baca sekarang!',
      time: '2 hari lalu',
      isRead: true,
    ),
    const NotificationItem(
      icon: Icons.people_outline_rounded,
      iconBg: AppColors.tertiary,
      title: 'Aktivitas Komunitas',
      body:
          'Ada diskusi baru di komunitas. Bergabunglah dan berbagi pengalaman!',
      time: '3 hari lalu',
      isRead: true,
    ),
    const NotificationItem(
      icon: Icons.emoji_events_rounded,
      iconBg: AppColors.info,
      title: 'Tantangan Harian',
      body:
          'Tantangan baru sudah siap untukmu! Selesaikan untuk mendapat rewards.',
      time: '4 hari lalu',
      isRead: true,
    ),
    const NotificationItem(
      icon: Icons.favorite_rounded,
      iconBg: AppColors.error,
      title: 'Motivasi Hari Ini',
      body:
          '"Setiap langkah kecil yang kamu ambil hari ini mendekatkanmu pada versi terbaik dirimu."',
      time: '5 hari lalu',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final notifications = initialNotifications ?? defaultNotifications;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 38 * 0.8,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tetap terhubung dengan progres pemulihanmu',
                    style: TextStyle(
                      fontSize: 30 * 0.42,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            Expanded(
              child:
                  notifications.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return NotificationItemTile(notification: notif);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Notifikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi tentang aktivitas dan pengingat harian akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
