import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

/// Motivational quote card widget for recovery education.
class EducationQuoteCard extends StatelessWidget {
  final String title;
  final String quote;
  final String author;
  final String assetPath;

  const EducationQuoteCard({
    super.key,
    this.title = 'Quote Hari Ini',
    this.quote =
        '"Perubahan kecil dalam kebiasaan sehari-hari bisa membawa perubahan besar dalam hidupmu."',
    this.author = '— James Clear',
    this.assetPath = 'assets/images/maskots/quote.png',
  });

  @override
  Widget build(BuildContext context) {
    final recoveryTheme = context.recoveryTheme;

    return Container(
      decoration: BoxDecoration(
        color: recoveryTheme.streakCardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 120, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: recoveryTheme.streakCardForeground,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  quote,
                  style: TextStyle(
                    color: recoveryTheme.streakCardForeground.withValues(
                      alpha: 0.9,
                    ),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  author,
                  style: TextStyle(
                    color: recoveryTheme.streakCardForeground.withValues(
                      alpha: 0.75,
                    ),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
                bottomRight: Radius.circular(18),
              ),
              child: Image.asset(assetPath, width: 140, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
