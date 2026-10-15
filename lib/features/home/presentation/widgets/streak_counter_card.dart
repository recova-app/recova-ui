import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

class StreakCounterCard extends StatelessWidget {
  final int currentStreak;
  final double progress;
  final List<String> streakCalendar;
  final List<String> relapseCalendar;
  final int goalDays;

  const StreakCounterCard({
    super.key,
    required this.currentStreak,
    required this.progress,
    required this.streakCalendar,
    required this.goalDays,
    this.relapseCalendar = const [],
  });

  @override
  Widget build(BuildContext context) {
    final recoveryTheme = context.recoveryTheme;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: recoveryTheme.streakCardBackground,
        gradient: recoveryTheme.streakGradient,
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 140, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak Kamu',
                      style: TextStyle(
                        color: recoveryTheme.streakCardForeground,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currentStreak Hari',
                      style: TextStyle(
                        color: recoveryTheme.streakCardForeground,
                        fontWeight: FontWeight.w800,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Setelah Melakukan Daily Check-in streak kamu akan terupdate di tengah malam',
                      style: TextStyle(
                        color: recoveryTheme.streakCardForeground.withOpacity(
                          0.85,
                        ),
                        fontSize: 9,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: -30,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                  ),
                  child: Image.asset(
                    'assets/images/home/gunung.png',
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              children: [
                Builder(
                  builder: (context) {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final monday = today.subtract(
                      Duration(days: now.weekday - 1),
                    );

                    final checkedDates =
                        streakCalendar.map((s) {
                          final d = DateTime.parse(s);
                          return DateTime(d.year, d.month, d.day);
                        }).toSet();

                    final relapseDates =
                        relapseCalendar.map((s) {
                          final d = DateTime.parse(s);
                          return DateTime(d.year, d.month, d.day);
                        }).toSet();

                    final dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final dayDate = monday.add(Duration(days: index));
                        final isToday = dayDate == today;
                        final isRelapse = relapseDates.contains(dayDate);
                        final isCheckedIn =
                            checkedDates.contains(dayDate) && !isRelapse;

                        return Column(
                          children: [
                            Text(
                              dayLabels[index],
                              style: TextStyle(
                                fontWeight:
                                    isToday ? FontWeight.w800 : FontWeight.w600,
                                color:
                                    isToday
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.onSurface
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (isRelapse)
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: recoveryTheme.relapseStatusColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            else if (isCheckedIn)
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: recoveryTheme.cleanStatusColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            else if (isToday)
                              Container(
                                width: 28,
                                height: 28,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: recoveryTheme.cleanStatusColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: recoveryTheme.cleanStatusBackground,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: recoveryTheme.cleanStatusColor
                                        .withOpacity(0.6),
                                    size: 16,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color:
                                      context.recoveryTheme.progressBackground,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Progress: $currentStreak / $goalDays Days',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 14,
                    backgroundColor: context.recoveryTheme.progressBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      recoveryTheme.cleanStatusColor,
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
