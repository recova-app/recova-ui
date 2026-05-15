import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/stats_cubit.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});
  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool _isAnalysisTab = true;
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    context.read<StatsCubit>().fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: BlocBuilder<StatsCubit, StatsState>(
          builder: (context, state) {
            if (state is StatsLoading || state is StatsInitial) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0C7A57)));
            }
            if (state is StatsLoadFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                      const SizedBox(height: 12),
                      Text(state.error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<StatsCubit>().fetchStats(),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C7A57)),
                        child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            }
            final data = (state as StatsLoadSuccess).data;
            final stats = data.statistics;
            return RefreshIndicator(
              color: const Color(0xFF0C7A57),
              onRefresh: () => context.read<StatsCubit>().fetchStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _hero(),
                    const SizedBox(height: 12),
                    _tabs(),
                    const SizedBox(height: 22),
                    if (_isAnalysisTab) ..._buildAnalysis(stats, data) else _historyPanel(data.relapses),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(15)),
        child: Image.asset('assets/images/logo.png', width: 64, height: 64),
      ),
      const Icon(Icons.notifications_none_rounded, color: Color(0xFF6B7280)),
    ],
  );

  Widget _hero() => Container(
    height: 154,
    decoration: BoxDecoration(color: const Color(0xFF0C7A57), borderRadius: BorderRadius.circular(20)),
    child: Stack(children: [
      const Positioned(
        left: 16, top: 40, right: 120,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mari Kita liat, Seberapa\nJauh Progresmu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 34 * 0.55, height: 1.1)),
          SizedBox(height: 8),
          Text('Satu langkah kecil setiap harinya', style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 10)),
        ]),
      ),
      Positioned(right: -35, bottom: -50, child: Image.asset('assets/images/home/task.png', width: 195, height: 195, fit: BoxFit.contain)),
    ]),
  );

  Widget _tabs() => Container(
    height: 36, padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(color: const Color(0xFFE1E1E1), borderRadius: BorderRadius.circular(30)),
    child: Row(children: [
      _tabItem('Analysis', _isAnalysisTab, () => setState(() => _isAnalysisTab = true)),
      _tabItem('History', !_isAnalysisTab, () => setState(() => _isAnalysisTab = false)),
    ]),
  );

  Widget _tabItem(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0C7A57) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFF444444), fontWeight: active ? FontWeight.w700 : FontWeight.w600))),
      ),
    ),
  );

  List<Widget> _buildAnalysis(RelapseStats stats, RelapseStatisticsResponse data) {
    final cleanDays = stats.streakCalendar.length;
    final successPercent = (stats.successRate * 100).round();
    return [
      _sectionTitle('Your Statistics', 'This is your overview for the last 90 days'),
      const SizedBox(height: 12),
      _statCards(stats, cleanDays, successPercent),
      const SizedBox(height: 22),
      _sectionTitle('Streak Calendar', 'This is your Streak calendar'),
      const SizedBox(height: 14),
      _calendar(stats),
      const SizedBox(height: 22),
      _sectionTitle('Time Of Day', 'When relapses occur throughout the day'),
      const SizedBox(height: 12),
      _donutPanel(data),
    ];
  }

  Widget _sectionTitle(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 43 * 0.55, fontWeight: FontWeight.w800)),
      Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF9AA3AA))),
    ],
  );

  Widget _statCards(RelapseStats stats, int cleanDays, int successPercent) => Column(children: [
    Row(children: [
      Expanded(flex: 3, child: Container(
        height: 220,
        decoration: BoxDecoration(color: const Color(0xFFDDE8E2), borderRadius: BorderRadius.circular(14)),
        child: Stack(clipBehavior: Clip.antiAlias, children: [
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Longest Streak', style: TextStyle(color: Color(0xFF5C6761), fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('${stats.longestStreak} Hari', style: const TextStyle(fontSize: 56 * 0.55, fontWeight: FontWeight.w800, color: Color(0xFF2E5948))),
          ])),
          Positioned(right: 25, bottom: -35, child: Image.asset('assets/images/home/longStreak.png', width: 200, fit: BoxFit.contain)),
        ]),
      )),
      const SizedBox(width: 10),
      Expanded(flex: 2, child: SizedBox(height: 220, child: Column(children: [
        Expanded(child: _miniCard(Icons.check_box_outlined, 'Success Rate', '$successPercent%', const Color(0xFFC8D5E8))),
        const SizedBox(height: 10),
        Expanded(child: _miniCard(Icons.calendar_month_outlined, 'Clean Days', '$cleanDays Hari', const Color(0xFFB6C3EE))),
      ]))),
    ]),
    const SizedBox(height: 10),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(color: const Color(0xFFE8DDCB), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total Check-ins', style: TextStyle(color: Color(0xFF6E6558), fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('${stats.totalCheckins}', style: const TextStyle(fontSize: 50 * 0.55, fontWeight: FontWeight.w800, color: Color(0xFF3B352D))),
        ])),
        Image.asset('assets/images/home/boredom.png', width: 120, height: 120, fit: BoxFit.contain),
      ]),
    ),
  ]);

  Widget _miniCard(IconData icon, String label, String value, Color bg) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 20),
      const Spacer(),
      Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4D5560))),
      Text(value, style: const TextStyle(fontSize: 44 * 0.55, fontWeight: FontWeight.w800, color: Color(0xFF273247), height: 1.1)),
    ]),
  );

  // ── Calendar ─────────────────────────────────────────────────────────────
  Widget _calendar(RelapseStats stats) {
    final streakDates = stats.streakCalendar.map((s) => s.substring(0, 10)).toSet();
    final relapseDates = stats.relapseCalendar.map((s) => s.substring(0, 10)).toSet();
    final year = _calendarMonth.year;
    final month = _calendarMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Build grid cells
    final cells = <_CalCell>[];
    // Leading blanks from previous month
    final prevMonth = DateTime(year, month, 0);
    for (int i = firstWeekday - 1; i > 0; i--) {
      cells.add(_CalCell(day: prevMonth.day - i + 1, isCurrentMonth: false));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final dateStr = '$year-${month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      final isRelapse = relapseDates.contains(dateStr);
      final isStreak = streakDates.contains(dateStr) && !isRelapse;
      final isToday = dateStr == todayStr;
      cells.add(_CalCell(day: d, isCurrentMonth: true, isStreak: isStreak, isRelapse: isRelapse, isToday: isToday));
    }
    // Trailing blanks
    int trailing = 7 - (cells.length % 7);
    if (trailing < 7) {
      for (int d = 1; d <= trailing; d++) {
        cells.add(_CalCell(day: d, isCurrentMonth: false));
      }
    }

    final weeks = <List<_CalCell>>[];
    for (int i = 0; i < cells.length; i += 7) {
      weeks.add(cells.sublist(i, i + 7));
    }

    final monthLabel = DateFormat('MMMM yyyy').format(_calendarMonth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(onTap: () => setState(() => _calendarMonth = DateTime(year, month - 1)), child: const Icon(Icons.chevron_left)),
          Text(monthLabel, style: const TextStyle(fontSize: 30 * 0.42, color: Color(0xFF666666), fontWeight: FontWeight.w600)),
          GestureDetector(onTap: () => setState(() => _calendarMonth = DateTime(year, month + 1)), child: const Icon(Icons.chevron_right)),
        ]),
        const SizedBox(height: 10),
        const Divider(),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text('Sen'), Text('Sel'), Text('Rab'), Text('Kam'), Text('Jum'), Text('Sab'), Text('Min'),
        ]),
        const SizedBox(height: 8),
        ...weeks.map((week) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: week.map((cell) {
            Color bgColor = Colors.transparent;
            Color textColor = cell.isCurrentMonth ? const Color(0xFF313131) : const Color(0xFFB8B8B8);
            BoxDecoration? decoration;

            if (cell.isRelapse) {
              bgColor = const Color(0xFFEF4444);
              textColor = Colors.white;
              decoration = const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle);
            } else if (cell.isStreak) {
              bgColor = const Color(0xFF39B96B);
              textColor = Colors.white;
              decoration = const BoxDecoration(color: Color(0xFF39B96B), shape: BoxShape.circle);
            } else if (cell.isToday) {
              decoration = BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0C7A57), width: 2));
              textColor = const Color(0xFF0C7A57);
            }

            return Container(
              width: 32, height: 32, alignment: Alignment.center,
              decoration: decoration,
              child: Text('${cell.day}', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
            );
          }).toList()),
        )),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _calendarLegend(const Color(0xFF39B96B), 'Clean'),
          const SizedBox(width: 16),
          _calendarLegend(const Color(0xFFEF4444), 'Relapse'),
          const SizedBox(width: 16),
          _calendarLegend(Colors.transparent, 'Today', border: const Color(0xFF0C7A57)),
        ]),
      ]),
    );
  }

  Widget _calendarLegend(Color color, String label, {Color? border}) => Row(children: [
    Container(
      width: 12, height: 12,
      decoration: BoxDecoration(
        color: color, shape: BoxShape.circle,
        border: border != null ? Border.all(color: border, width: 2) : null,
      ),
    ),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
  ]);

  // ── Donut (Time Of Day) ──────────────────────────────────────────────────
  Widget _donutPanel(RelapseStatisticsResponse data) {
    final dist = data.hourlyRelapseDistribution;
    final peakHours = data.peakRelapseHoursUtc;
    final summary = data.relapseTimeSummary?.summary;

    // Group hours into time-of-day buckets
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

    // Build legend items
    final segments = <_DonutSegment>[
      _DonutSegment('Morning (5-11)', morning, const Color(0xFFF59E0B)),
      _DonutSegment('Afternoon (12-16)', afternoon, const Color(0xFF3B82F6)),
      _DonutSegment('Evening (17-21)', evening, const Color(0xFF6A34C9)),
      _DonutSegment('Night (22-4)', night, const Color(0xFF3950C3)),
    ];

    // Peak hours text
    final peakText = peakHours.isNotEmpty
        ? peakHours.map((h) => '${h.toString().padLeft(2, '0')}:00').join(', ')
        : '-';

    return _panel(
      child: Column(children: [
        const SizedBox(height: 4),
        SizedBox(
          height: 220,
          child: total > 0
              ? CustomPaint(painter: _DonutPainterData(segments: segments, total: total), child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('$total', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF273247))),
                    const Text('Relapses', style: TextStyle(fontSize: 12, color: Color(0xFF9AA3AA), fontWeight: FontWeight.w600)),
                  ]),
                ))
              : const Center(child: Text('Belum ada data', style: TextStyle(color: Color(0xFF9AA3AA)))),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 14, runSpacing: 8, alignment: WrapAlignment.center, children: segments.map((s) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text('${s.label} (${s.count})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF4A5460))),
          ],
        )).toList()),
        const SizedBox(height: 10),
        if (peakHours.isNotEmpty)
          Container(
            width: double.infinity, padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.access_time, size: 16, color: Color(0xFFD97706)),
              const SizedBox(width: 8),
              Expanded(child: Text('Peak hours: $peakText', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)))),
            ]),
          ),
        const SizedBox(height: 10),
        // if (summary != null && summary.isNotEmpty) _tip(summary),
        if (data.relapseTimeSummary != null) ...[
          const SizedBox(height: 10),
          _timeSummaryCard(data.relapseTimeSummary!),
        ],
      ]),
    );
  }

  Widget _timeSummaryCard(RelapseTimeSummary summary) => Container(
    width: double.infinity, padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFE6EEEA), borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.analytics_outlined, size: 16, color: Color(0xFF3F51B5)),
          const SizedBox(width: 8),
          Text(summary.title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A237E), fontSize: 13)),
        ]),
        const SizedBox(height: 8),
        Text(summary.analysis, style: const TextStyle(fontSize: 12, color: Color(0xFF3949AB))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFC5CAE9), borderRadius: BorderRadius.circular(8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFF1A237E)),
              const SizedBox(width: 6),
              Expanded(child: Text(summary.summary, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A237E)))),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _panel({required Widget child}) => Container(
    width: double.infinity, padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
    decoration: BoxDecoration(color: const Color(0xFFE2E9E5), borderRadius: BorderRadius.circular(16)),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F2), borderRadius: BorderRadius.circular(16)),
      child: child,
    ),
  );

  Widget _tip(String text) => Container(
    width: double.infinity, padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xFFE6EEEA), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      const Icon(Icons.info_outline, size: 16, color: Color(0xFF5D8D7F)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF4E5A55), fontWeight: FontWeight.w600))),
    ]),
  );

  // ── History Tab ──────────────────────────────────────────────────────────
  Widget _historyPanel(List<RelapseEntry> relapses) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Relapse History', 'This is your relapse history'),
      const SizedBox(height: 20),
      if (relapses.isEmpty)
        Container(
          width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFFEFFBEE), borderRadius: BorderRadius.circular(12)),
          child: const Column(children: [
            Icon(Icons.celebration, size: 40, color: Color(0xFF22C55E)),
            SizedBox(height: 8),
            Text('Belum ada relapse!', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2E5948))),
            Text('Pertahankan progresmu', style: TextStyle(color: Color(0xFF5C6761))),
          ]),
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
    ]);
  }

  Widget _historyTimelineItem({required RelapseEntry relapse, required bool isFirst, required bool isLast}) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(width: 24, child: Stack(alignment: Alignment.center, children: [
          Positioned(
            top: isFirst ? 14 : 0, bottom: isLast ? null : 0,
            child: Container(width: 4, color: const Color(0xFFE2E2E2)),
          ),
          Positioned(top: 14, child: Container(
            width: 14, height: 14,
            decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
          )),
        ])),
        const SizedBox(width: 8),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${relapse.relapseDayName}, ${relapse.relapseDate}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF272727), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.emoji_emotions_outlined, size: 14, color: Color(0xFF9AA3AA)),
                const SizedBox(width: 4),
                Text('Mood: ${relapse.mood}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ]),
              const SizedBox(height: 4),
              Text(relapse.commitment, style: const TextStyle(color: Color(0xFF7F1D1D), fontSize: 13)),
              if (relapse.relapseTrigger.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 4, children: relapse.relapseTrigger.map((t) => _tag(t)).toList()),
              ],
            ]),
          ),
        )),
      ]),
    );
  }

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
  );
}

// ── Helper classes ──────────────────────────────────────────────────────────

class _CalCell {
  final int day;
  final bool isCurrentMonth;
  final bool isStreak;
  final bool isRelapse;
  final bool isToday;
  const _CalCell({required this.day, this.isCurrentMonth = true, this.isStreak = false, this.isRelapse = false, this.isToday = false});
}

class _DonutSegment {
  final String label;
  final int count;
  final Color color;
  const _DonutSegment(this.label, this.count, this.color);
}

class _DonutPainterData extends CustomPainter {
  final List<_DonutSegment> segments;
  final int total;
  _DonutPainterData({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.33;
    final rect = Rect.fromCircle(center: c, radius: r);
    final strokeWidth = 26.0;

    // Draw background ring
    final bg = Paint()
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
      final paint = Paint()
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
