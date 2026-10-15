import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

class StreakBadge extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? streakDays;
  final String? quote;
  final String? mascotAssetPath;
  final Color? backgroundColor;

  const StreakBadge({
    super.key,
    required this.title,
    required this.subtitle,
    this.streakDays,
    this.quote,
    this.mascotAssetPath,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final recoveryTheme = context.recoveryTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBg = backgroundColor ?? recoveryTheme.streakCardBackground;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: effectiveBg,
        gradient: backgroundColor == null ? recoveryTheme.streakGradient : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (mascotAssetPath != null) ...[
            const SizedBox(height: 8),
            Image.asset(mascotAssetPath!, width: 200, height: 200),
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: TextStyle(
              color:
                  streakDays != null
                      ? recoveryTheme.streakCardForeground.withOpacity(0.9)
                      : recoveryTheme.streakCardForeground,
              fontSize: streakDays != null ? 14 : 24,
              fontWeight:
                  streakDays != null ? FontWeight.w600 : FontWeight.w800,
              height: streakDays != null ? 1.0 : 1.1,
            ),
          ),
          if (streakDays != null) ...[
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder:
                  (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
              child: Text(
                key: ValueKey<int>(streakDays!),
                '$streakDays',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: recoveryTheme.streakCardForeground,
                  height: 1.1,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: recoveryTheme.streakCardForeground,
            ),
          ),
          if (quote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                quote!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: recoveryTheme.streakCardForeground.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
