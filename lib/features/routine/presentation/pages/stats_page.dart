import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/features/routine/presentation/cubit/stats_cubit.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/features/routine/presentation/widgets/stats_history_panel.dart';
import 'package:recova/features/routine/presentation/widgets/stats_relapse_time_chart.dart';
import 'package:recova/features/routine/presentation/widgets/stats_streak_calendar.dart';
import 'package:recova/features/routine/presentation/widgets/stats_summary_cards.dart';
import 'package:recova/features/routine/presentation/widgets/stats_trigger_bar_chart.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:recova/features/notifications/presentation/pages/notification_page.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<StatsCubit, StatsState>(
          builder: (context, state) {
            if (state is StatsLoading || state is StatsInitial) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            }
            if (state is StatsLoadFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(state.error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            () => context.read<StatsCubit>().fetchStats(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Coba Lagi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final data = (state as StatsLoadSuccess).data;
            final stats = data.statistics;
            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () => context.read<StatsCubit>().fetchStats(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    _hero(context),
                    const SizedBox(height: 12),
                    _tabs(context),
                    const SizedBox(height: 22),
                    if (_isAnalysisTab)
                      ..._buildAnalysis(stats, data)
                    else
                      StatsHistoryPanel(relapses: data.relapses),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset('assets/images/logo.png', width: 64, height: 64),
        ),
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              ),
        ),
      ],
    );
  }

  Widget _hero(BuildContext context) {
    final recoveryTheme = context.recoveryTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 154,
      decoration: BoxDecoration(
        color: recoveryTheme.streakCardBackground,
        gradient: recoveryTheme.streakGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 40,
            right: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mari Kita liat, Seberapa\nJauh Progresmu',
                  style: TextStyle(
                    color: recoveryTheme.streakCardForeground,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Satu langkah kecil setiap harinya',
                  style: TextStyle(
                    color: recoveryTheme.streakCardForeground.withOpacity(0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -35,
            bottom: -50,
            child: Image.asset(
              'assets/images/home/task.png',
              width: 195,
              height: 195,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color:
            isDark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabItem(
            'Analisis',
            _isAnalysisTab,
            () => setState(() => _isAnalysisTab = true),
          ),
          _tabItem(
            'Histori Relapse',
            !_isAnalysisTab,
            () => setState(() => _isAnalysisTab = false),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(String label, bool active, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : colorScheme.onSurfaceVariant,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnalysis(
    RelapseStats stats,
    RelapseStatisticsResponse data,
  ) {
    final cleanDays = stats.streakCalendar.length;
    final successPercent = (stats.successRate * 100).round();
    return [
      _sectionTitle(
        'Statistik Kamu',
        'Ini adalah ringkasan untuk 90 hari terakhir',
      ),
      const SizedBox(height: 12),
      StatsSummaryCards(
        stats: stats,
        cleanDays: cleanDays,
        successPercent: successPercent,
      ),
      const SizedBox(height: 22),
      _sectionTitle(
        'Kalender Streak',
        'Ini adalah catatan kalender Streak Kamu',
      ),
      const SizedBox(height: 14),
      StatsStreakCalendar(
        stats: stats,
        calendarMonth: _calendarMonth,
        onMonthChanged: (newMonth) {
          setState(() {
            _calendarMonth = newMonth;
          });
        },
      ),
      const SizedBox(height: 22),
      _sectionTitle(
        'Waktu Relapse',
        'Analisis Waktu ketika kamu mengalami relapse',
      ),
      const SizedBox(height: 12),
      StatsRelapseTimeChart(data: data),
      const SizedBox(height: 22),
      _sectionTitle(
        'Trigger Relapse',
        'Frekuensi trigger yang menyebabkan relapse',
      ),
      const SizedBox(height: 12),
      StatsTriggerBarChart(data: data),
    ];
  }

  Widget _sectionTitle(String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 43 * 0.55,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
