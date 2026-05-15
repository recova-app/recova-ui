import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample notification data (static for now)
    final List<_NotificationItem> notifications = [
      _NotificationItem(
        icon: Icons.check_circle_outline_rounded,
        iconBg: const Color(0xFF22C55E),
        title: 'Daily Check-In Reminder',
        body: 'Jangan lupa check-in hari ini untuk mempertahankan streak kamu!',
        time: 'Hari ini, 09:15',
        isRead: false,
      ),
      _NotificationItem(
        icon: Icons.local_fire_department_rounded,
        iconBg: const Color(0xFFF59E0B),
        title: 'Streak Milestone 🎉',
        body: 'Selamat! Kamu sudah mencapai 7 hari streak. Terus pertahankan!',
        time: 'Kemarin, 00:00',
        isRead: false,
      ),
      _NotificationItem(
        icon: Icons.auto_stories_rounded,
        iconBg: const Color(0xFF3B82F6),
        title: 'Konten Baru Tersedia',
        body: 'Ada artikel baru tentang strategi pemulihan. Yuk baca sekarang!',
        time: '2 hari lalu',
        isRead: true,
      ),
      _NotificationItem(
        icon: Icons.people_outline_rounded,
        iconBg: const Color(0xFF8B5CF6),
        title: 'Aktivitas Komunitas',
        body: 'Ada diskusi baru di komunitas. Bergabunglah dan berbagi pengalaman!',
        time: '3 hari lalu',
        isRead: true,
      ),
      _NotificationItem(
        icon: Icons.emoji_events_rounded,
        iconBg: const Color(0xFF0EA5E9),
        title: 'Tantangan Harian',
        body: 'Tantangan baru sudah siap untukmu! Selesaikan untuk mendapat rewards.',
        time: '4 hari lalu',
        isRead: true,
      ),
      _NotificationItem(
        icon: Icons.favorite_rounded,
        iconBg: const Color(0xFFEF4444),
        title: 'Motivasi Hari Ini',
        body: '"Setiap langkah kecil yang kamu ambil hari ini mendekatkanmu pada versi terbaik dirimu."',
        time: '5 hari lalu',
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Fixed header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar — logo + back button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
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
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Page title
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 38 * 0.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tetap terhubung dengan progres pemulihanmu',
                    style: TextStyle(
                      fontSize: 30 * 0.42,
                      color: Color(0xFF8B98A0),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),

            // ── Scrollable notification list ──
            Expanded(
              child: notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return _NotificationCard(notification: notif);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                color: const Color(0xFFEAF9F1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 40,
                color: Color(0xFF38B768),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Notifikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Notifikasi tentang aktivitas dan pengingat harian akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B98A0),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification data model ──

class _NotificationItem {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String body;
  final String time;
  final bool isRead;

  const _NotificationItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}

// ── Notification card widget ──

class _NotificationCard extends StatelessWidget {
  final _NotificationItem notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead
            ? const Color(0xFFF7F7F7)
            : const Color(0xFFEAF9F1),
        borderRadius: BorderRadius.circular(14),
        border: notification.isRead
            ? null
            : Border.all(
                color: const Color(0xFFD1FAE5),
                width: 1,
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: notification.iconBg.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification.icon,
              color: notification.iconBg,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight:
                              notification.isRead ? FontWeight.w600 : FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF111111),
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB0B8C1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
