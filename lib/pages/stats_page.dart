import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:recova/controllers/home/home_controller.dart';
import 'package:recova/models/statistics_model.dart';
import 'package:recova/widgets/recova_ui.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late final HomeController _homeController;
  int _modeIndex = 0;
  int _chartScopeIndex = 0;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeController.fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final state = _homeController.state.value;

        if (state is HomeLoading || state is HomeInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeLoadFailure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFD65A5A),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gagal memuat statistik: ${state.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _homeController.fetchHomeData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E6B52),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! HomeLoadSuccess) {
          return const SizedBox.shrink();
        }

        final stats = state.statistics;
        final totalDays = 32;

        return RefreshIndicator(
          color: const Color(0xFF0E6B52),
          onRefresh: _homeController.fetchHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecovaTopBar(
                    onLeftPressed: () {},
                    onRightPressed: () {},
                    leftIcon: Icons.settings,
                  ),
                  const SizedBox(height: 28),
                  RecovaHeroBanner(
                    title: 'Mari Kita lihat,\nSeberapa Jauh Progressmu',
                    subtitle: 'Satu langkah kecil setiap harinya',
                    imagePath: 'assets/images/home/icon_review.png',
                    height: 150,
                    imageWidth: 112,
                    contentPadding: const EdgeInsets.fromLTRB(20, 22, 14, 18),
                  ),
                  const SizedBox(height: 18),
                  RecovaSegmentedControl(
                    labels: const ['Analysis', 'History'],
                    selectedIndex: _modeIndex,
                    onChanged: (index) {
                      setState(() {
                        _modeIndex = index;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child:
                        _modeIndex == 0
                            ? _buildAnalysisView(stats, totalDays)
                            : _buildHistoryView(stats),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnalysisView(Statistics stats, int totalDays) {
    final triggerData =
        _chartScopeIndex == 0
            ? const [
              RecovaBarData(
                label: 'Boredom',
                value: 6,
                color: Color(0xFF0E6B52),
              ),
              RecovaBarData(
                label: 'Stress',
                value: 4,
                color: Color(0xFF6887A3),
              ),
              RecovaBarData(label: 'Media', value: 3, color: Color(0xFFFFC514)),
              RecovaBarData(label: 'Mood', value: 3, color: Color(0xFF16B6A3)),
              RecovaBarData(
                label: 'Location',
                value: 3,
                color: Color(0xFFA36DFF),
              ),
            ]
            : const [
              RecovaBarData(
                label: 'Boredom',
                value: 7,
                color: Color(0xFF0E6B52),
              ),
              RecovaBarData(
                label: 'Stress',
                value: 5,
                color: Color(0xFF6887A3),
              ),
              RecovaBarData(label: 'Media', value: 4, color: Color(0xFFFFC514)),
              RecovaBarData(label: 'Mood', value: 4, color: Color(0xFF16B6A3)),
              RecovaBarData(
                label: 'Location',
                value: 4,
                color: Color(0xFFA36DFF),
              ),
              RecovaBarData(
                label: 'Lonely',
                value: 2,
                color: Color(0xFFE8777A),
              ),
            ];

    final ringSegments =
        _chartScopeIndex == 0
            ? const [
              RecovaRingSegment(
                value: 68,
                color: Color(0xFF4A5BD9),
                label: 'Evening',
              ),
              RecovaRingSegment(
                value: 32,
                color: Color(0xFF7B3EDB),
                label: 'Night',
              ),
            ]
            : const [
              RecovaRingSegment(
                value: 58,
                color: Color(0xFF4A5BD9),
                label: 'Evening',
              ),
              RecovaRingSegment(
                value: 42,
                color: Color(0xFF7B3EDB),
                label: 'Night',
              ),
            ];

    return Column(
      key: const ValueKey('analysis'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RecovaSectionHeader(
          title: 'Your Statistics',
          subtitle: 'This is your overview for the last 90 days',
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 230,
                child: RecovaMetricCard(
                  title: 'Longest Streak',
                  value: '${stats.longestStreak} Hari',
                  backgroundColor: const Color(0xFFEFF8F0),
                  accentColor: const Color(0xFF0E6B52),
                  assetPath: 'assets/images/home/icon_checkin.png',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  SizedBox(
                    height: 109,
                    child: RecovaMetricCard(
                      title: 'Success Rate',
                      value: '${_successRate(stats, totalDays)}%',
                      backgroundColor: const Color(0xFFE6F0FF),
                      accentColor: const Color(0xFF4B6BFF),
                      icon: Icons.check_box_outline_blank,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 109,
                    child: RecovaMetricCard(
                      title: 'Clean Days',
                      value: '${stats.totalCheckins} Hari',
                      backgroundColor: const Color(0xFFE7EEFF),
                      accentColor: const Color(0xFF6B7CF5),
                      icon: Icons.calendar_month_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 114,
          child: RecovaMetricCard(
            title: 'Most Common Trigger',
            value: 'Boredom',
            backgroundColor: const Color(0xFFF8E9D2),
            accentColor: const Color(0xFFD49333),
            assetPath: 'assets/images/home/icon_exercise.png',
          ),
        ),
        const SizedBox(height: 28),
        const RecovaSectionHeader(
          title: 'Trigger & Urges',
          subtitle: 'This is your overview for the last 90 days',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8F5),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Show: '),
                  RecovaChartChip(
                    label: 'Top 5',
                    selected: _chartScopeIndex == 0,
                    onTap: () => setState(() => _chartScopeIndex = 0),
                  ),
                  const SizedBox(width: 10),
                  RecovaChartChip(
                    label: 'All',
                    selected: _chartScopeIndex == 1,
                    onTap: () => setState(() => _chartScopeIndex = 1),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              RecovaBarChart(data: triggerData),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const RecovaInfoCard(
          text:
              'Your data shows that Boredom is your main trigger. Developing specific coping strategies for idle moments can help reduce relapse risk.',
        ),
        const SizedBox(height: 28),
        const RecovaSectionHeader(
          title: 'Time Of Day',
          subtitle: 'When relapses Occur throught the day',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8F5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RecovaDonutChart(segments: ringSegments, size: 200),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 10,
                children: const [
                  _LegendDot(
                    color: Color(0xFF7B3EDB),
                    label: 'Evening (18-22)',
                  ),
                  _LegendDot(color: Color(0xFF4A5BD9), label: 'Night (23-4)'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const RecovaInfoCard(
          text:
              'Night (9PM-5AM) is your highest risk period. Creating a specific routine during these hours can reduce impulsive behavior.',
        ),
      ],
    );
  }

  Widget _buildHistoryView(Statistics stats) {
    final historyEntries = _buildHistoryEntries(stats);

    return Column(
      key: const ValueKey('history'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RecovaSectionHeader(
          title: 'Relapse History',
          subtitle: 'This is your relapse history for the last 90 days',
        ),
        const SizedBox(height: 20),
        if (historyEntries.isEmpty)
          const RecovaInfoCard(
            text: 'Belum ada riwayat yang bisa ditampilkan saat ini.',
          )
        else
          Column(
            children: [
              for (final entry in historyEntries) ...[
                RecovaTimelineEntry(
                  time: entry.time,
                  reason: entry.reason,
                  mood: entry.mood,
                  trigger: entry.trigger,
                ),
                const SizedBox(height: 26),
              ],
            ],
          ),
      ],
    );
  }

  int _successRate(Statistics stats, int totalDays) {
    if (totalDays <= 0) return 0;
    final rate = ((stats.currentStreak / totalDays) * 100).round();
    return rate.clamp(0, 100);
  }

  List<_HistoryEntry> _buildHistoryEntries(Statistics stats) {
    final entries = stats.streakCalendar.reversed.take(3).toList();
    if (entries.isEmpty) return [];

    return entries.map((date) {
      final parsed = DateTime.tryParse(date) ?? DateTime.now();
      return _HistoryEntry(
        time: _formatLongDate(parsed),
        reason: 'Check-in harian',
        mood: 'Normal',
        trigger: 'Tidak dicatat',
      );
    }).toList();
  }

  String _formatLongDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _HistoryEntry {
  final String time;
  final String reason;
  final String mood;
  final String trigger;

  const _HistoryEntry({
    required this.time,
    required this.reason,
    required this.mood,
    required this.trigger,
  });
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF40464A)),
        ),
      ],
    );
  }
}
