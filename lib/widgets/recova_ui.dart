import 'dart:math' as math;

import 'package:flutter/material.dart';

class RecovaTopBar extends StatelessWidget {
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;
  final IconData leftIcon;
  final IconData rightIcon;

  const RecovaTopBar({
    super.key,
    this.onLeftPressed,
    this.onRightPressed,
    this.leftIcon = Icons.settings,
    this.rightIcon = Icons.notifications_none,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _TopCircleIcon(
          icon: leftIcon,
          onPressed: onLeftPressed,
          backgroundColor: const Color(0xFF0E9F66),
          foregroundColor: Colors.white,
        ),
        _TopCircleIcon(
          icon: rightIcon,
          onPressed: onRightPressed,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111111),
          borderColor: const Color(0xFFE6E6E6),
        ),
      ],
    );
  }
}

class _TopCircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  const _TopCircleIcon({
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Icon(icon, color: foregroundColor, size: 20),
      ),
    );
  }
}

class RecovaHeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final double height;
  final Widget? footer;
  final LinearGradient gradient;
  final EdgeInsets contentPadding;
  final double imageWidth;

  const RecovaHeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.height = 180,
    this.footer,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF0E6B52), Color(0xFF0F7A58)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.contentPadding = const EdgeInsets.all(20),
    this.imageWidth = 110,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              right: -6,
              top: 0,
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white.withValues(alpha: 0.18),
                size: 120,
              ),
            ),
            Positioned(
              right: -15,
              bottom: footer != null ? 40 : -10,
              child: SizedBox(
                width: imageWidth + 50,
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: contentPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 11,
                                  height: 1.15,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (footer != null) ...[const SizedBox(height: 12), footer!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecovaSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const RecovaSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:
                      selected ? const Color(0xFF0E6B52) : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class RecovaSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const RecovaSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Color(0xFF83919B)),
        ),
      ],
    );
  }
}

class RecovaFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String assetPath;
  final Color backgroundColor;
  final Color iconBackground;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color titleColor;
  final Color subtitleColor;
  final double assetSize;

  const RecovaFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.backgroundColor,
    required this.iconBackground,
    this.onTap,
    this.trailing,
    this.titleColor = const Color(0xFF111111),
    this.subtitleColor = const Color(0xFF808892),
    this.assetSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Image.asset(
                assetPath,
                width: assetSize,
                height: assetSize,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: card,
    );
  }
}

class RecovaMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final Color accentColor;
  final IconData? icon;
  final String? assetPath;
  final bool largeValue;

  const RecovaMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.accentColor,
    this.icon,
    this.assetPath,
    this.largeValue = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 20, color: const Color(0xFF1C1C1C)),
          if (icon != null) const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: largeValue ? 28 : 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111111),
              height: 1,
            ),
          ),
          if (assetPath != null) ...[
            const Spacer(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                assetPath!,
                width: 78,
                height: 78,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RecovaInfoCard extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color iconColor;

  const RecovaInfoCard({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFFEAF5F2),
    this.iconColor = const Color(0xFF0E6B52),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF5F6B73),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecovaTimelineEntry extends StatelessWidget {
  final String time;
  final String reason;
  final String mood;
  final String trigger;

  const RecovaTimelineEntry({
    super.key,
    required this.time,
    required this.reason,
    required this.mood,
    required this.trigger,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 4,
              height: 124,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFFAF5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HistoryRow(label: 'time', value: time),
                _HistoryRow(label: 'reason', value: reason),
                _HistoryRow(label: 'Mood', value: mood),
                _HistoryRow(label: 'Trigger', value: trigger),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label  $value',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF222222),
          height: 1.1,
        ),
      ),
    );
  }
}

class RecovaChartChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const RecovaChartChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0E6B52) : const Color(0xFFE3E7E5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF1B1B1B),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class RecovaBarChart extends StatelessWidget {
  final List<RecovaBarData> data;
  final Color barColor;
  final double height;

  const RecovaBarChart({
    super.key,
    required this.data,
    this.barColor = const Color(0xFF0E6B52),
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue =
        data.isEmpty ? 1 : data.map((e) => e.value).reduce(math.max);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            data.map((item) {
              final normalized = maxValue == 0 ? 0.0 : item.value / maxValue;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item.value.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6D7A84),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 22,
                      height: 100 * normalized.clamp(0.1, 1.0),
                      decoration: BoxDecoration(
                        color: item.color ?? barColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF1D1D1D),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

class RecovaBarData {
  final String label;
  final double value;
  final Color? color;

  const RecovaBarData({required this.label, required this.value, this.color});
}

class RecovaDonutChart extends StatelessWidget {
  final List<RecovaRingSegment> segments;
  final double size;

  const RecovaDonutChart({super.key, required this.segments, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DonutPainter(segments),
    );
  }
}

class RecovaRingSegment {
  final double value;
  final Color color;
  final String label;

  const RecovaRingSegment({
    required this.value,
    required this.color,
    required this.label,
  });
}

class _DonutPainter extends CustomPainter {
  final List<RecovaRingSegment> segments;

  _DonutPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final strokeWidth = radius * 0.28;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );
    final total = segments.fold<double>(0, (sum, item) => sum + item.value);
    var startAngle = -math.pi / 2;

    for (final segment in segments) {
      final sweepAngle =
          total == 0 ? 0.0 : (segment.value / total) * 2 * math.pi;
      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round
            ..color = segment.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
