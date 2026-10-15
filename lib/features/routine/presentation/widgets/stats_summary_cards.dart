import 'package:flutter/material.dart';
import 'package:recova/models/relapse_statistics_model.dart';

class StatsSummaryCards extends StatelessWidget {
  final RelapseStats stats;
  final int cleanDays;
  final int successPercent;

  const StatsSummaryCards({
    super.key,
    required this.stats,
    required this.cleanDays,
    required this.successPercent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final longestStreakBg =
        isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFDDE8E2);
    final longestStreakLabelColor =
        isDark ? colorScheme.onSurfaceVariant : const Color(0xFF5C6761);
    final longestStreakValueColor =
        isDark ? colorScheme.primary : const Color(0xFF2E5948);

    final successRateBg =
        isDark ? colorScheme.surfaceContainerHigh : const Color(0xFFC8D5E8);
    final cleanDaysBg =
        isDark ? colorScheme.surfaceContainer : const Color(0xFFB6C3EE);

    final totalCheckinsBg =
        isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFE8DDCB);
    final totalCheckinsLabelColor =
        isDark ? colorScheme.onSurfaceVariant : const Color(0xFF6E6558);
    final totalCheckinsValueColor =
        isDark ? colorScheme.onSurface : const Color(0xFF3B352D);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: longestStreakBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  clipBehavior: Clip.antiAlias,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Longest Streak',
                            style: TextStyle(
                              color: longestStreakLabelColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats.longestStreak} Hari',
                            style: TextStyle(
                              fontSize: 56 * 0.55,
                              fontWeight: FontWeight.w800,
                              color: longestStreakValueColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 25,
                      bottom: -35,
                      child: Image.asset(
                        'assets/images/home/longStreak.png',
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 220,
                child: Column(
                  children: [
                    Expanded(
                      child: _miniCard(
                        context: context,
                        icon: Icons.check_box_outlined,
                        label: 'Success Rate',
                        value: '$successPercent%',
                        bg: successRateBg,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _miniCard(
                        context: context,
                        icon: Icons.calendar_month_outlined,
                        label: 'Clean Days',
                        value: '$cleanDays Hari',
                        bg: cleanDaysBg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          decoration: BoxDecoration(
            color: totalCheckinsBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Check-ins',
                      style: TextStyle(
                        color: totalCheckinsLabelColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stats.totalCheckins}',
                      style: TextStyle(
                        fontSize: 50 * 0.55,
                        fontWeight: FontWeight.w800,
                        color: totalCheckinsValueColor,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                'assets/images/home/boredom.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color bg,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? colorScheme.onSurface : colorScheme.onSurface,
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color:
                  isDark
                      ? colorScheme.onSurfaceVariant
                      : const Color(0xFF4D5560),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 44 * 0.55,
              fontWeight: FontWeight.w800,
              color: isDark ? colorScheme.onSurface : const Color(0xFF273247),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
