import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import '../models/coach_chat_message.dart';

/// Modular chat bubble widget rendering user requests and markdown-formatted AI responses.
class CoachChatBubble extends StatelessWidget {
  final CoachChatMessage message;
  final String avatarPath;
  final String personaTitle;
  final double avatarSize;

  const CoachChatBubble({
    super.key,
    required this.message,
    required this.avatarPath,
    required this.personaTitle,
    this.avatarSize = 36,
  });

  static String formatTimestamp(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inSeconds < 60) return 'JUST NOW';

    final sameDay =
        now.year == createdAt.year &&
        now.month == createdAt.month &&
        now.day == createdAt.day;

    final hh = createdAt.hour.toString().padLeft(2, '0');
    final mm = createdAt.minute.toString().padLeft(2, '0');
    if (sameDay) return '$hh:$mm';

    final dd = createdAt.day.toString().padLeft(2, '0');
    final mo = createdAt.month.toString().padLeft(2, '0');
    return '$dd/$mo $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = formatTimestamp(message.createdAt);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final recoveryTheme = context.recoveryTheme;

    if (!message.isAI) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timeLabel,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                avatarPath,
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  personaTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? colorScheme.surface
                      : recoveryTheme.accentSurfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border:
                  isDark ? Border.all(color: colorScheme.outlineVariant) : null,
            ),
            child: MarkdownBody(
              data: message.text,
              selectable: false,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  height: 1.5,
                ),
                strong: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
                em: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
                listBullet: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeLabel,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
