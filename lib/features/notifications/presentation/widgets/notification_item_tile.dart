import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import '../models/notification_item.dart';

/// Card widget rendering an individual notification item with read/unread visual indicators.
class NotificationItemTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;

  const NotificationItemTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final recoveryTheme = context.recoveryTheme;

    final unreadBg =
        isDark
            ? recoveryTheme.accentSurface
            : recoveryTheme.accentSurfaceSubtle;
    final readBg =
        isDark
            ? colorScheme.surface
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? readBg : unreadBg,
          borderRadius: BorderRadius.circular(14),
          border:
              notification.isRead
                  ? null
                  : Border.all(
                    color:
                        isDark
                            ? colorScheme.primary.withValues(alpha: 0.4)
                            : colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: notification.iconBg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notification.icon,
                color: notification.iconBg,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
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
                                notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
