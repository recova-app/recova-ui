import 'package:flutter/material.dart';

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
    BenefitItem(
      emoji: '💛',
      title: 'Hubungan yang lebih erat',
    ),
    BenefitItem(
      emoji: '⭐',
      title: 'Peningkatan rasa percaya diri',
    ),
    BenefitItem(
      emoji: '🔥',
      title: 'Lebih banyak energi dan motivasi',
    ),
    BenefitItem(
      emoji: '💪',
      title: 'Peningkatan gairah dan kehidupan seks',
    ),
    BenefitItem(
      emoji: '🧘',
      title: 'Peningkatan pengendalian diri',
    ),
    BenefitItem(
      emoji: '🎯',
      title: 'Peningkatan fokus dan kejernihan pikiran',
    ),
    BenefitItem(
      emoji: '🌿',
      title: 'Pikiran yang murni dan sehat',
    ),
    BenefitItem(
      emoji: '😊',
      title: 'Suasana hati yang lebih baik',
    ),
    BenefitItem(
      emoji: '🕊️',
      title: 'Stres dan kecemasan berkurang',
    ),
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
      (index) => Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(
          index * 0.05,
          0.5 + (index * 0.05),
          curve: Curves.easeOutCubic,
        ),
      )),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Manfaat Bebas Pornografi',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Benefits List
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

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/homepage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Selanjutnya',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Benefit Item Model
class BenefitItem {
  final String emoji;
  final String title;

  BenefitItem({
    required this.emoji,
    required this.title,
  });
}

// Benefit Card Widget
class BenefitCard extends StatelessWidget {
  final BenefitItem benefit;

  const BenefitCard({
    super.key,
    required this.benefit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Emoji
          Text(
            benefit.emoji,
            style: const TextStyle(fontSize: 24),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              benefit.title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
