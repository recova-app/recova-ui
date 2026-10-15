import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/services/notification_service.dart';

/// Interactive switch card enabling or disabling local scheduled daily recovery reminders.
class ProfileNotificationToggleCard extends StatefulWidget {
  final String? checkinTime;

  const ProfileNotificationToggleCard({super.key, this.checkinTime});

  @override
  State<ProfileNotificationToggleCard> createState() =>
      _ProfileNotificationToggleCardState();
}

class _ProfileNotificationToggleCardState
    extends State<ProfileNotificationToggleCard> {
  bool _isEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final scheduled =
          await AwesomeNotifications().listScheduledNotifications();
      if (mounted) {
        setState(() {
          _isEnabled = scheduled.isNotEmpty;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggle(bool value) async {
    setState(() => _loading = true);
    if (value) {
      await NotificationService.requestPermission();
      await NotificationService.scheduleDailyNotification(
        checkinTime: widget.checkinTime,
      );
    } else {
      await NotificationService.cancelAll();
    }
    if (mounted) {
      setState(() {
        _isEnabled = value;
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Pengingat harian diaktifkan 🔔'
                : 'Pengingat harian dinonaktifkan 🔕',
          ),
          backgroundColor:
              value
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final recoveryTheme = context.recoveryTheme;

    final cardBg =
        isDark
            ? recoveryTheme.accentSurface
            : recoveryTheme.accentSurfaceSubtle;

    return Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? colorScheme.surfaceContainerHighest
                          : recoveryTheme.accentSurfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reminder Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aktifkan Atau Nonaktifkan Pengingat Harian Kamu',
                      style: TextStyle(
                        fontSize: 8.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _loading
                  ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                    ),
                  )
                  : Switch(
                    value: _isEnabled,
                    onChanged: _toggle,
                    activeColor: colorScheme.onPrimary,
                    activeTrackColor: colorScheme.primary,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: colorScheme.outlineVariant,
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
