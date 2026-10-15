import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

class CommunityHubMenuCard extends StatelessWidget {
  const CommunityHubMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    this.imageWidth = 56,
    this.imageHeight = 56,
    this.imageOffset = Offset.zero,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String assetPath;
  final double imageWidth;
  final double imageHeight;
  final Offset imageOffset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final recoveryTheme = context.recoveryTheme;

    final cardBg =
        isDark
            ? colorScheme.surfaceContainerHighest
            : recoveryTheme.accentSurface;
    final titleColor = colorScheme.onSurface;
    final subtitleColor = colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Transform.translate(
              offset: imageOffset,
              child: Image.asset(
                assetPath,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                      height: 1.25,
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
