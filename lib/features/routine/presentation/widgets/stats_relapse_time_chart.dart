import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/models/relapse_statistics_model.dart';

class DonutSegment {
  final String label;
  final int count;
  final Color color;

  const DonutSegment(this.label, this.count, this.color);
}

class DonutPainterData extends CustomPainter {
  final List<DonutSegment> segments;
  final int total;

  DonutPainterData({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.33;
    final rect = Rect.fromCircle(center: c, radius: r);
    const strokeWidth = 26.0;

    final bg =
        Paint()
          ..color = const Color(0xFFE3E7F9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, bg);

    if (total == 0) return;

    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      if (seg.count == 0) continue;
      final sweep = (seg.count / total) * math.pi * 2;
      final paint =
          Paint()
            ..color = seg.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StatsRelapseTimeChart extends StatelessWidget {
  final RelapseStatisticsResponse data;

  const StatsRelapseTimeChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dist = data.hourlyRelapseDistribution;
    final peakHours = data.peakRelapseHoursUtc;

    int morning = 0, afternoon = 0, evening = 0, night = 0;
    for (final d in dist) {
      final h = d.hourUtc;
      if (h >= 5 && h < 12) {
        morning += d.relapseCount;
      } else if (h >= 12 && h < 17) {
        afternoon += d.relapseCount;
      } else if (h >= 17 && h < 22) {
        evening += d.relapseCount;
      } else {
        night += d.relapseCount;
      }
    }
    final total = morning + afternoon + evening + night;

    final segments = <DonutSegment>[
      DonutSegment('Pagi (5-11)', morning, const Color(0xFFF59E0B)),
      DonutSegment('Siang (12-16)', afternoon, const Color(0xFF3B82F6)),
      DonutSegment('Sore (17-21)', evening, const Color(0xFF6A34C9)),
      DonutSegment('Malam (22-4)', night, const Color(0xFF3950C3)),
    ];

    final peakText =
        peakHours.isNotEmpty
            ? peakHours
                .map((h) => '${h.toString().padLeft(2, '0')}:00')
                .join(', ')
            : '-';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        color:
            isDark
                ? colorScheme.surfaceContainerHighest
                : const Color(0xFFE2E9E5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : const Color(0xFFF1F5F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const SizedBox(height: 4),
            SizedBox(
              height: 220,
              child:
                  total > 0
                      ? CustomPaint(
                        painter: DonutPainterData(
                          segments: segments,
                          total: total,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$total',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Relapses',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Center(
                        child: Text(
                          'Belum ada data',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children:
                  segments
                      .map(
                        (s) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: s.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${s.label} (${s.count})',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 10),
            if (peakHours.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? colorScheme.surfaceContainerHighest
                          : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color:
                          isDark
                              ? colorScheme.primary
                              : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Peak hours: $peakText',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark
                                  ? colorScheme.onSurface
                                  : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (data.relapseTimeSummary != null) ...[
              const SizedBox(height: 10),
              _buildTimeSummaryCard(context, data.relapseTimeSummary!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSummaryCard(
    BuildContext context,
    RelapseTimeSummary summary,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final recoveryTheme = context.recoveryTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDark
                ? colorScheme.surfaceContainerHighest
                : recoveryTheme.accentSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                summary.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary.analysis,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? colorScheme.surface
                      : recoveryTheme.cleanStatusBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    summary.summary,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
