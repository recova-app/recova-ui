import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

class HomeFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String assetPath;
  final Color? bg;
  final bool arrow;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? subtitleColor;

  const HomeFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    this.bg,
    this.arrow = false,
    this.onTap,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        bg != null
            ? (isDark ? context.recoveryTheme.accentSurface : bg!)
            : context.recoveryTheme.accentSurface;
    final effectiveTitleColor = titleColor ?? colorScheme.onSurface;
    final effectiveSubtitleColor =
        subtitleColor ?? colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: effectiveTitleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: effectiveSubtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (arrow)
                  Icon(Icons.chevron_right, color: effectiveTitleColor),
              ],
            ),
          ),
          Positioned(
            right: -10,
            bottom: -15,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(16),
              ),
              child: Image.asset(assetPath, width: 80, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
