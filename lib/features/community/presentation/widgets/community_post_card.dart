import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/models/post_model.dart';

String maskCommunityName(String? rawName) {
  final name = (rawName ?? '').trim();
  if (name.isEmpty) return 'Anonim';

  final visibleLength = name.length >= 3 ? 3 : 1;
  final visiblePart = name.substring(0, visibleLength);
  return '$visiblePart*****';
}

String formatRelativeCommunityTime(DateTime dateTime) {
  final now = DateTime.now();
  final localTime = dateTime.toLocal();
  final diff = now.difference(localTime);

  if (diff.inMinutes < 1) return 'baru saja';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}j';
  if (diff.inDays < 7) return '${diff.inDays}h';

  final hour = localTime.hour.toString().padLeft(2, '0');
  final minute = localTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComments,
  });

  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                maskCommunityName(post.username),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${formatRelativeCommunityTime(post.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: recoveryTheme.accentSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      '${post.userStreak ?? 0}',
                      style: TextStyle(
                        color: recoveryTheme.warningStatusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.local_fire_department,
                      size: 12,
                      color: recoveryTheme.warningStatusColor,
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _CommunityActionButton(
                onTap: onComments,
                count: post.commentCount,
                icon: Icons.chat_bubble_outline,
                iconColor: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              _CommunityActionButton(
                onTap: onLike,
                count: post.likeCount,
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                iconColor:
                    post.isLiked
                        ? colorScheme.secondary
                        : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommunityActionButton extends StatelessWidget {
  const _CommunityActionButton({
    required this.onTap,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  final VoidCallback onTap;
  final int count;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 36),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 5),
            Icon(icon, size: 18, color: iconColor),
          ],
        ),
      ),
    );
  }
}
