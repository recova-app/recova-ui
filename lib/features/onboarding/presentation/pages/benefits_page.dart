import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import '../widgets/onboarding_button.dart';

class BenefitsPage extends StatefulWidget {
  const BenefitsPage({super.key});

  @override
  State<BenefitsPage> createState() => _BenefitsPageState();
}

class _BenefitsPageState extends State<BenefitsPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late List<Animation<Offset>> _slideAnimations;

  final List<BenefitItem> _benefits = [
    BenefitItem(emoji: '💛', title: 'Hubungan sosial yang lebih erat'),
    BenefitItem(emoji: '⭐', title: 'Peningkatan rasa percaya diri'),
    BenefitItem(emoji: '🔥', title: 'Lebih banyak energi dan motivasi'),
    BenefitItem(emoji: '💪', title: 'Peningkatan gairah dan kehidupan seks'),
    BenefitItem(emoji: '🧘', title: 'Peningkatan pengendalian diri'),
    BenefitItem(emoji: '🎯', title: 'Peningkatan fokus dan kejernihan pikiran'),
    BenefitItem(emoji: '🌿', title: 'Pikiran yang murni dan sehat'),
    BenefitItem(emoji: '😊', title: 'Suasana hati yang lebih baik'),
    BenefitItem(emoji: '🕊️', title: 'Stres dan kecemasan berkurang'),
  ];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimations = List.generate(
      _benefits.length,
      (index) =>
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _slideController,
              curve: Interval(
                index * 0.05,
                0.5 + (index * 0.05),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Keuntungan Berhenti',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inilah yang akan kamu dapatkan ketika berhasil mengatasi kebiasaan ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _benefits.length,
                itemBuilder: (context, index) {
                  return SlideTransition(
                    position: _slideAnimations[index],
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: BenefitCard(benefit: _benefits[index]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: OnboardingButton(
                text: 'Selanjutnya',
                onPressed: () {
                  Navigator.pushNamed(context, '/homepage');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BenefitItem {
  final String emoji;
  final String title;

  BenefitItem({required this.emoji, required this.title});
}

class BenefitCard extends StatelessWidget {
  final BenefitItem benefit;

  const BenefitCard({super.key, required this.benefit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(benefit.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              benefit.title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
