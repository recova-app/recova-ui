import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:recova/models/relapse_statistics_model.dart';

class StatsTriggerBarChart extends StatefulWidget {
  final RelapseStatisticsResponse data;

  const StatsTriggerBarChart({super.key, required this.data});

  @override
  State<StatsTriggerBarChart> createState() => _StatsTriggerBarChartState();
}

class _StatsTriggerBarChartState extends State<StatsTriggerBarChart> {
  bool _showAllTriggers = false;

  static const List<Color> _barColors = [
    Color(0xFF0C7A57),
    Color(0xFF3950C3),
    Color(0xFFF59E0B),
    Color(0xFF0EA5A3),
    Color(0xFF8B5CF6),
    Color(0xFFE95A6D),
    Color(0xFF2563EB),
    Color(0xFFD97706),
    Color(0xFF059669),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final triggers = widget.data.relapseTriggerDistribution;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (triggers.isEmpty) {
      return _buildPanel(
        context: context,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'Belum ada data trigger',
              style: TextStyle(
                color: Color(0xFF9AA3AA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final sorted = List<RelapseTriggerDistribution>.from(triggers)
      ..sort((a, b) => b.relapseTriggerCount.compareTo(a.relapseTriggerCount));

    final displayed = _showAllTriggers ? sorted : sorted.take(5).toList();
    final maxCount = displayed
        .map((e) => e.relapseTriggerCount)
        .reduce(math.max);

    return _buildPanel(
      context: context,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Show:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 8),
              _triggerToggle(
                'Top 5',
                !_showAllTriggers,
                () => setState(() => _showAllTriggers = false),
              ),
              const SizedBox(width: 6),
              _triggerToggle(
                'All',
                _showAllTriggers,
                () => setState(() => _showAllTriggers = true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 230,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 26,
                  height: 190,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(maxCount < 5 ? maxCount + 1 : 6, (
                      i,
                    ) {
                      final steps = math.max(1, maxCount < 5 ? maxCount : 5);
                      final val = maxCount - ((maxCount / steps) * i).round();
                      return Text(
                        '$val',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9AA3AA),
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(displayed.length, (i) {
                            final item = displayed[i];
                            final fraction =
                                maxCount > 0
                                    ? item.relapseTriggerCount.toDouble() /
                                        maxCount.toDouble()
                                    : 0.0;
                            final color = _barColors[i % _barColors.length];
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${item.relapseTriggerCount}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      height: fraction * 160,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(6),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(height: 1, color: const Color(0xFFD1D5DB)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(displayed.length, (i) {
                          final label = displayed[i].relapseTrigger;
                          final capitalised =
                              label.isNotEmpty
                                  ? '${label[0].toUpperCase()}${label.substring(1)}'
                                  : label;
                          return Expanded(
                            child: Text(
                              capitalised,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A5460),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (widget.data.relapseTimeriggerSummary != null)
            _triggerSummaryCard(widget.data.relapseTimeriggerSummary!),
        ],
      ),
    );
  }

  Widget _buildPanel({required BuildContext context, required Widget child}) {
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
        child: child,
      ),
    );
  }

  Widget _triggerToggle(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0C7A57) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _triggerSummaryCard(RelapseTimeSummary summary) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFE6EEEA),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFD1FAE5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.info_outline,
            size: 16,
            color: Color(0xFF0C7A57),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            summary.summary,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4E5A55),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
