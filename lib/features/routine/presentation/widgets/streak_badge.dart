import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? streakDays;
  final String? quote;
  final String? mascotAssetPath;
  final Color backgroundColor;

  const StreakBadge({
    super.key,
    required this.title,
    required this.subtitle,
    this.streakDays,
    this.quote,
    this.mascotAssetPath,
    this.backgroundColor = const Color(0xFF136E4D),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
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
                  streakDays != null ? const Color(0xFFD1FAE5) : Colors.white,
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
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFD1FAE5),
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
