import 'package:flutter/material.dart';
import 'package:recova/models/relapse_statistics_model.dart';

class StatsHistoryPanel extends StatelessWidget {
  final List<RelapseEntry> relapses;

  const StatsHistoryPanel({super.key, required this.relapses});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histori Relapse',
              style: TextStyle(
                fontSize: 43 * 0.55,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Ini adalah histori relapse kamu',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (relapses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEFFBEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.celebration, size: 40, color: Color(0xFF22C55E)),
                SizedBox(height: 8),
                Text(
                  'Belum ada relapse!',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E5948),
                  ),
                ),
                Text(
                  'Pertahankan progresmu',
                  style: TextStyle(color: Color(0xFF5C6761)),
                ),
              ],
            ),
          )
        else
          ...relapses.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            return _historyTimelineItem(
              relapse: r,
              isFirst: i == 0,
              isLast: i == relapses.length - 1,
            );
          }),
      ],
    );
  }

  Widget _historyTimelineItem({
    required RelapseEntry relapse,
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: isFirst ? 14 : 0,
                  bottom: isLast ? null : 0,
                  child: Container(width: 4, color: const Color(0xFFE2E2E2)),
                ),
                Positioned(
                  top: 14,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${relapse.relapseDayName}, ${relapse.relapseDate}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF272727),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_emotions_outlined,
                          size: 14,
                          color: Color(0xFF9AA3AA),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Mood: ${relapse.mood}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      relapse.commitment,
                      style: const TextStyle(
                        color: Color(0xFF7F1D1D),
                        fontSize: 13,
                      ),
                    ),
                    if (relapse.relapseTrigger.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children:
                            relapse.relapseTrigger.map((t) => _tag(t)).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFEF4444),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 8,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
