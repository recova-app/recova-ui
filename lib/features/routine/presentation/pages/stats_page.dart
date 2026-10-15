import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/stats_cubit.dart';
import 'package:recova/features/routine/presentation/widgets/stats_history_panel.dart';
import 'package:recova/features/routine/presentation/widgets/stats_relapse_time_chart.dart';
import 'package:recova/features/routine/presentation/widgets/stats_streak_calendar.dart';
import 'package:recova/features/routine/presentation/widgets/stats_summary_cards.dart';
import 'package:recova/features/routine/presentation/widgets/stats_trigger_bar_chart.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:recova/pages/notification_page.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<StatsCubit, StatsState>(
          builder: (context, state) {
            if (state is StatsLoading || state is StatsInitial) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0C7A57)),
              );
            }
            if (state is StatsLoadFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 12),
                      Text(state.error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            () => context.read<StatsCubit>().fetchStats(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C7A57),
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

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Image.asset('assets/images/logo.png', width: 64, height: 64),
      ),
      GestureDetector(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: Color(0xFF6B7280),
        ),
      ),
    ],
  );

  Widget _hero() => Container(
    height: 154,
    decoration: BoxDecoration(
      color: const Color(0xFF0C7A57),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Stack(
      children: [
        const Positioned(
          left: 16,
          top: 40,
          right: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mari Kita liat, Seberapa\nJauh Progresmu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 34 * 0.55,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Satu langkah kecil setiap harinya',
                style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 10),
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

  Widget _tabs() => Container(
    height: 36,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color:
          Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : const Color(0xFFE1E1E1),
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

  Widget _tabItem(String label, bool active, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active ? const Color(0xFF0C7A57) : Colors.transparent,
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
