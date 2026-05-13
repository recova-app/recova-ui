import 'dart:math' as math;
import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool _isAnalysisTab = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.star, size: 16),
                  ),
                  const Icon(Icons.notifications_none_rounded),
                ],
              ),
              const SizedBox(height: 20),
              _hero(),
              const SizedBox(height: 12),
              _tabs(),
              const SizedBox(height: 22),
              if (_isAnalysisTab) ...[
                const Text(
                  'Your Statistics',
                  style: TextStyle(
                    fontSize: 43 * 0.55,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'This is your overview for the last 90 days',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9AA3AA)),
                ),
                const SizedBox(height: 12),
                _statCards(),
                const SizedBox(height: 22),
                const Text(
                  'Streak Calendar',
                  style: TextStyle(
                    fontSize: 43 * 0.55,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'This is your Streak calendar',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9AA3AA)),
                ),
                const SizedBox(height: 14),
                _calendar(),
                const SizedBox(height: 22),
                const Text(
                  'Trigger & Urges',
                  style: TextStyle(
                    fontSize: 43 * 0.55,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'This is your overview for the last 90 days',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9AA3AA)),
                ),
                const SizedBox(height: 12),
                _barPanel(),
                const SizedBox(height: 22),
                const Text(
                  'Time Of Day',
                  style: TextStyle(
                    fontSize: 43 * 0.55,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'When relapses Occur troughout the day',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9AA3AA)),
                ),
                const SizedBox(height: 12),
                _donutPanel(),
              ] else ...[
                _historyPanel(),
              ]
            ],
          ),
        ),
      ),
    );
  }

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
                style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 11),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          bottom: -20,
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
      color: const Color(0xFFE1E1E1),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAnalysisTab = true),
            child: Container(
              decoration: BoxDecoration(
                color: _isAnalysisTab ? const Color(0xFF0C7A57) : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  'Analysis',
                  style: TextStyle(
                    color: _isAnalysisTab ? Colors.white : const Color(0xFF444444),
                    fontWeight: _isAnalysisTab ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAnalysisTab = false),
            child: Container(
              decoration: BoxDecoration(
                color: !_isAnalysisTab ? const Color(0xFF0C7A57) : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  'History',
                  style: TextStyle(
                    color: !_isAnalysisTab ? Colors.white : const Color(0xFF444444),
                    fontWeight: !_isAnalysisTab ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _statCards() => Column(
    children: [
      Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE8E2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                clipBehavior: Clip.antiAlias,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Longest Streak',
                          style: TextStyle(
                            color: Color(0xFF5C6761),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '23 Hari',
                          style: TextStyle(
                            fontSize: 56 * 0.55,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E5948),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: -15,
                    child: Image.asset(
                      'assets/images/home/longStreak.png',
                      width: 220, // Disesuaikan agar muat
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 220,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8D5E8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_box_outlined, size: 20),
                          Spacer(),
                          Text(
                            'Success Rate',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4D5560),
                            ),
                          ),
                          Text(
                            '98%',
                            style: TextStyle(
                              fontSize: 44 * 0.55,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF273247),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB6C3EE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 20),
                          Spacer(),
                          Text(
                            'Clean Days',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4D5560),
                            ),
                          ),
                          Text(
                            '33 Hari',
                            style: TextStyle(
                              fontSize: 44 * 0.55,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF273247),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8DDCB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Most Common Trigger',
                    style: TextStyle(
                      color: Color(0xFF6E6558),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Boredom',
                    style: TextStyle(
                      fontSize: 50 * 0.55,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3B352D),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Image.asset(
                'assets/images/home/boredom.png',
                width: 120, // Disesuaikan agar muat
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _calendar() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F4F4),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.chevron_left),
            Text(
              'Agustus 2025',
              style: TextStyle(
                fontSize: 30 * 0.42,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.chevron_right),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('SEN'),
            Text('SEL'),
            Text('RAB'),
            Text('KAM'),
            Text('JUM'),
            Text('SAB'),
            Text('MIN'),
          ],
        ),
        const SizedBox(height: 8),
        ...[
          ['1', '2', '3', '4', '5', '6', '7'],
          ['8', '9', '10', '11', '12', '13', '14'],
          ['15', '16', '17', '18', '19', '20', '21'],
          ['22', '23', '24', '25', '26', '27', '28'],
          ['29', '30', '31', '1', '2', '3', '4'],
        ].map(
          (week) => Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  week.map((d) {
                    final isActive = d == '21';
                    final isOrange = d == '19' || d == '20';
                    final faded =
                        ['1', '2', '3', '4'].contains(d) &&
                        week == ['29', '30', '31', '1', '2', '3', '4'];
                    return Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration:
                          isActive
                              ? const BoxDecoration(
                                color: Color(0xFF39B96B),
                                shape: BoxShape.circle,
                              )
                              : null,
                      child: Text(
                        d,
                        style: TextStyle(
                          color:
                              isActive
                                  ? Colors.white
                                  : faded
                                  ? const Color(0xFFB8B8B8)
                                  : isOrange
                                  ? const Color(0xFFF0A43A)
                                  : const Color(0xFF313131),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _barPanel() => _panel(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Show:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0C7A57),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Top 5',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE3DF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'All',
                style: TextStyle(
                  color: Color(0xFF5D6661),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 190,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _Bar(value: 6, color: Color(0xFF0F9580), label: 'Boredom'),
              _Bar(value: 4, color: Color(0xFF4B7B8E), label: 'Stress'),
              _Bar(value: 3, color: Color(0xFFF4C500), label: 'Media'),
              _Bar(value: 3, color: Color(0xFF0DAA97), label: 'Mood'),
              _Bar(value: 3, color: Color(0xFF7E57E7), label: 'Location'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _tip(
          'Your data shows that Boredom are your main triggers. Developing specific coping strategies f...',
        ),
      ],
    ),
  );

  Widget _donutPanel() => _panel(
    child: Column(
      children: [
        const SizedBox(height: 4),
        SizedBox(
          height: 220,
          child: CustomPaint(painter: _DonutPainter(), child: const Center()),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rotate_right, size: 14, color: Color(0xFF5D3FD3)),
            SizedBox(width: 6),
            Text(
              'Evening (18-22)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5460),
              ),
            ),
            SizedBox(width: 14),
            Icon(Icons.rotate_right, size: 14, color: Color(0xFF3950C3)),
            SizedBox(width: 6),
            Text(
              'Night (23-4)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5460),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _tip(
          'Night (9PM-5AM) is your highest risk period. Creating a specific routine during these hours c...',
        ),
      ],
    ),
  );

  Widget _panel({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
    decoration: BoxDecoration(
      color: const Color(0xFFE2E9E5),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    ),
  );

  Widget _tip(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFE6EEEA),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, size: 16, color: Color(0xFF5D8D7F)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4E5A55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _historyPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Relapse History',
          style: TextStyle(
            fontSize: 43 * 0.55,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          'This is your relapse history for the last 90 days',
          style: TextStyle(fontSize: 14, color: Color(0xFF9AA3AA)),
        ),
        const SizedBox(height: 20),
        _historyTimelineItem(isFirst: true, isLast: false),
        _historyTimelineItem(isFirst: false, isLast: false),
        _historyTimelineItem(isFirst: false, isLast: true),
      ],
    );
  }

  Widget _historyTimelineItem({required bool isFirst, required bool isLast}) {
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
                  child: Container(
                    width: 4,
                    color: const Color(0xFFE2E2E2),
                  ),
                ),
                Positioned(
                  top: 14,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4D4D4),
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
                  color: const Color(0xFFEFFBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wednesday, 11 April 2026',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF272727),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Saya relapse karena tidak kuat menahan nafsu',
                      style: TextStyle(
                        color: Color(0xFF2E5948),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _tag('Boredom'),
                        const SizedBox(width: 8),
                        _tag('Media'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF45B980),
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
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.color, required this.label});
  final int value;
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    final h = value * 24.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 11, color: Color(0xFF56615B)),
        ),
        const SizedBox(height: 6),
        Container(
          width: 18,
          height: h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.33;
    final rect = Rect.fromCircle(center: c, radius: r);
    final bg =
        Paint()
          ..color = const Color(0xFFE3E7F9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, bg);
    final n =
        Paint()
          ..color = const Color(0xFF3950C3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round;
    final e =
        Paint()
          ..color = const Color(0xFF6A34C9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 26
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi * 0.15, math.pi * 1.55, false, n);
    canvas.drawArc(rect, math.pi * 1.95, math.pi * 0.45, false, e);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
