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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE8E2),
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
                          const Text(
                            'Longest Streak',
                            style: TextStyle(
                              color: Color(0xFF5C6761),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stats.longestStreak} Hari',
                            style: const TextStyle(
                              fontSize: 56 * 0.55,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E5948),
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
                        Icons.check_box_outlined,
                        'Success Rate',
                        '$successPercent%',
                        const Color(0xFFC8D5E8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _miniCard(
                        Icons.calendar_month_outlined,
                        'Clean Days',
                        '$cleanDays Hari',
                        const Color(0xFFB6C3EE),
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
            color: const Color(0xFFE8DDCB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Check-ins',
                      style: TextStyle(
                        color: Color(0xFF6E6558),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stats.totalCheckins}',
                      style: const TextStyle(
                        fontSize: 50 * 0.55,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3B352D),
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

  Widget _miniCard(IconData icon, String label, String value, Color bg) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF4D5560),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 44 * 0.55,
                fontWeight: FontWeight.w800,
                color: Color(0xFF273247),
                height: 1.1,
              ),
            ),
          ],
        ),
      );
}
