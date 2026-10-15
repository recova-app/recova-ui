import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

    final monthLabel = DateFormat('MMMM yyyy').format(calendarMonth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => onMonthChanged(DateTime(year, month - 1)),
                child: const Icon(Icons.chevron_left),
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 30 * 0.42,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => onMonthChanged(DateTime(year, month + 1)),
                child: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Sen'),
              Text('Sel'),
              Text('Rab'),
              Text('Kam'),
              Text('Jum'),
              Text('Sab'),
              Text('Min'),
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
                              ? const Color(0xFF313131)
                              : const Color(0xFFB8B8B8);
                      BoxDecoration? decoration;

                      if (cell.isRelapse) {
                        bgColor = const Color(0xFFEF4444);
                        textColor = Colors.white;
                        decoration = const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        );
                      } else if (cell.isStreak) {
                        bgColor = const Color(0xFF39B96B);
                        textColor = Colors.white;
                        decoration = const BoxDecoration(
                          color: Color(0xFF39B96B),
                          shape: BoxShape.circle,
                        );
                      } else if (cell.isToday) {
                        decoration = BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0C7A57),
                            width: 2,
                          ),
                        );
                        textColor = const Color(0xFF0C7A57);
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
              _calendarLegend(const Color(0xFF39B96B), 'Clean'),
              const SizedBox(width: 16),
              _calendarLegend(const Color(0xFFEF4444), 'Relapse'),
              const SizedBox(width: 16),
              _calendarLegend(
                Colors.transparent,
                'Today',
                border: const Color(0xFF0C7A57),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendarLegend(Color color, String label, {Color? border}) => Row(
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
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF666666),
        ),
      ),
    ],
  );
}
