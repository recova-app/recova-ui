import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

/// Reusable settings card tile with mascot graphic illustration.
class ProfileSettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String assetPath;
  final Color? iconBgColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ProfileSettingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    this.iconBgColor,
    this.iconColor,
    this.onTap,
  });

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
    final effectiveIconBg =
        iconBgColor ??
        (isDark
            ? colorScheme.surfaceContainerHighest
            : recoveryTheme.accentSurfaceSubtle);
    final effectiveIconColor = iconColor ?? colorScheme.primary;

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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: effectiveIconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: effectiveIconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -10,
            bottom: -15,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(12),
              ),
              child: Image.asset(assetPath, width: 70, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
