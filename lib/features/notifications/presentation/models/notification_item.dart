import 'package:flutter/material.dart';

/// Presentation data model representing a notification event.
class NotificationItem {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String body;
  final String time;
  final bool isRead;

  const NotificationItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}
