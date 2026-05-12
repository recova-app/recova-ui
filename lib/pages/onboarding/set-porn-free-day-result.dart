import 'package:flutter/material.dart';

class SetPornFreeDayResultPage extends StatefulWidget {
  final String selectedGoal;

  const SetPornFreeDayResultPage({
    super.key,
    this.selectedGoal = '3 days',
  });

  @override
  State<SetPornFreeDayResultPage> createState() => _SetPornFreeDayResultPageState();
}

class _SetPornFreeDayResultPageState extends State<SetPornFreeDayResultPage>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start scale animation
    _scaleController.forward();

    // Auto navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/know-your-why');
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti background
            ...List.generate(8, (index) => _buildConfetti(index)),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  SizedBox(
                      width: 200,
                      height: 200,
                      child: Image.asset(
                        'assets/images/maskots/set-porn-free-day-result.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  const SizedBox(height: 60),

                  // Goal text
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _scaleController,
                        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
                      ),
                    ),
                    child: Text(
                      '${widget.selectedGoal} goal set!',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfetti(int index) {
    final colors = [
      Colors.yellow.shade400,
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.green.shade300,
      Colors.orange.shade400,
    ];

    final shapes = ['circle', 'rectangle', 'curve'];
    final color = colors[index % colors.length];
    final shape = shapes[index % shapes.length];

    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        final progress = (_confettiController.value + (index * 0.1)) % 1.0;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Positioned(
          left: (index * 50.0 + 20) % screenWidth,
          top: -20 + (progress * (screenHeight + 40)),
          child: Transform.rotate(
            angle: progress * 6.28 * 2, // 2 full rotations
            child: Container(
              width: shape == 'rectangle' ? 8 : 6,
              height: shape == 'curve' ? 12 : 6,
              decoration: BoxDecoration(
                color: color,
                shape: shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: shape == 'curve'
                    ? BorderRadius.circular(6)
                    : (shape == 'rectangle' ? BorderRadius.circular(2) : null),
              ),
            ),
          ),
        );
      },
    );
  }
}
