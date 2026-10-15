import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/models/relapse_statistics_model.dart';

class CalCell {
  final int day;
  final bool isCurrentMonth;
  final bool isStreak;
  final bool isRelapse;
  final bool isToday;

  const CalCell({
    required this.day,
    this.isCurrentMonth = true,
    this.isStreak = false,
    this.isRelapse = false,
    this.isToday = false,
  });
}

class StatsStreakCalendar extends StatelessWidget {
  final RelapseStats stats;
  final DateTime calendarMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const StatsStreakCalendar({
    super.key,
    required this.stats,
    required this.calendarMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final streakDates =
        stats.streakCalendar.map((s) => s.substring(0, 10)).toSet();
    final relapseDates =
        stats.relapseCalendar.map((s) => s.substring(0, 10)).toSet();
    final year = calendarMonth.year;
    final month = calendarMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Build grid cells
    final cells = <CalCell>[];
    // Leading blanks from previous month
    final prevMonth = DateTime(year, month, 0);
    for (int i = firstWeekday - 1; i > 0; i--) {
      cells.add(CalCell(day: prevMonth.day - i + 1, isCurrentMonth: false));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final dateStr =
          '$year-${month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      final isRelapse = relapseDates.contains(dateStr);
      final isStreak = streakDates.contains(dateStr) && !isRelapse;
      final isToday = dateStr == todayStr;
      cells.add(
        CalCell(
          day: d,
          isCurrentMonth: true,
          isStreak: isStreak,
          isRelapse: isRelapse,
          isToday: isToday,
        ),
      );
    }
    // Trailing blanks
    int trailing = 7 - (cells.length % 7);
    if (trailing < 7) {
      for (int d = 1; d <= trailing; d++) {
        cells.add(CalCell(day: d, isCurrentMonth: false));
      }
    }

    final weeks = <List<CalCell>>[];
    for (int i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;
    final monthLabel = DateFormat('MMMM yyyy').format(calendarMonth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
                onPressed: () => onMonthChanged(DateTime(year, month - 1)),
              ),
              Text(
                monthLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: colorScheme.onSurface),
                onPressed: () => onMonthChanged(DateTime(year, month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: colorScheme.outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final day in [
                'Sen',
                'Sel',
                'Rab',
                'Kam',
                'Jum',
                'Sab',
                'Min',
              ])
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...weeks.map(
            (week) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    week.map((cell) {
                      Color bgColor = Colors.transparent;
                      Color textColor =
                          cell.isCurrentMonth
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant.withOpacity(0.4);
                      BoxDecoration? decoration;

                      if (cell.isRelapse) {
                        bgColor = recoveryTheme.relapseStatusColor;
                        textColor = Colors.white;
                        decoration = BoxDecoration(
                          color: recoveryTheme.relapseStatusColor,
                          shape: BoxShape.circle,
                        );
                      } else if (cell.isStreak) {
                        bgColor = recoveryTheme.cleanStatusColor;
                        textColor = Colors.white;
                        decoration = BoxDecoration(
                          color: recoveryTheme.cleanStatusColor,
                          shape: BoxShape.circle,
                        );
                      } else if (cell.isToday) {
                        decoration = BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        );
                        textColor = colorScheme.primary;
                      }

                      return Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: decoration,
                        child: Text(
                          '${cell.day}',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calendarLegend(context, recoveryTheme.cleanStatusColor, 'Clean'),
              const SizedBox(width: 16),
              _calendarLegend(
                context,
                recoveryTheme.relapseStatusColor,
                'Relapse',
              ),
              const SizedBox(width: 16),
              _calendarLegend(
                context,
                Colors.transparent,
                'Today',
                border: colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendarLegend(
    BuildContext context,
    Color color,
    String label, {
    Color? border,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border != null ? Border.all(color: border, width: 2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
