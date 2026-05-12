import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/onboarding_state.dart';

class KnowYourWhyPage extends StatefulWidget {
  const KnowYourWhyPage({super.key});

  @override
  State<KnowYourWhyPage> createState() => _KnowYourWhyPageState();
}

class _KnowYourWhyPageState extends State<KnowYourWhyPage> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_updateButtonState);
    // Set default text
    _reasonController.text =
        "Saya ingin lebih banyak motivasi untuk mengejar impian saya.";
    _isButtonEnabled = true;
  }

  @override
  void dispose() {
    _reasonController.removeListener(_updateButtonState);
    _reasonController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _reasonController.text.trim().isNotEmpty;
    });
  }

  void _saveWhy() {
    if (_reasonController.text.trim().isNotEmpty) {
      OnboardingState().recoveryReason = _reasonController.text.trim();
      Navigator.pushNamed(context, '/why-checkin');
    }
  }

  void _showPopularReasons() {
    // Show popular reasons bottom sheet or navigate to popular reasons page
  }

  void _promptMe() {
    // Show AI prompt functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: ListView(
            children: [
              // Main Content
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.large),

                    Container(
                      width: 220,
                      height: 220,
                      child: Image.asset(
                        'assets/images/maskots/know-your-why.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),

                    const SizedBox(height: AppSpacing.large),

                    // Main instruction
                    Text(
                      'Tuliskan SATU alasan mengapa kamu memilih untuk berhenti menonton pornografi.',
                      textAlign: TextAlign.center,
                      style: AppText.h2.copyWith(
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        fontFamily: 'Inter',
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.medium),

                    const SizedBox(height: AppSpacing.large),

                    // Text Input
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.small),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFDDDDDD),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: TextField(
                        controller: _reasonController,
                        maxLines: 3,
                        style: AppText.body.copyWith(fontSize: 16, height: 1.4),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Tulis alasanmu di sini...',
                        ),
                        onChanged: (_) => _updateButtonState(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.large),

                    // Helper buttons row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.medium,
                        vertical: AppSpacing.small,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: AppSpacing.large),

                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.large),

              // Bottom Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _saveWhy : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isButtonEnabled
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFBDBDBD),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Simpan alasan saya',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for happy brain character
class HappyBrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final brainPaint =
        Paint()
          ..color = const Color(0xFFB39DDB)
          ..style = PaintingStyle.fill;

    final facePaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    // Draw brain shape
    final brainPath = Path();
    brainPath.addOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.8,
        height: size.height * 0.7,
      ),
    );
    canvas.drawPath(brainPath, brainPaint);

    // Draw happy eyes
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.4),
      3,
      facePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.4),
      3,
      facePaint,
    );

    // Draw happy mouth
    final mouthPath = Path();
    mouthPath.moveTo(size.width * 0.4, size.height * 0.6);
    mouthPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.7,
      size.width * 0.6,
      size.height * 0.6,
    );

    final mouthPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawPath(mouthPath, mouthPaint);

    // Draw stick arms
    final armPaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.05, size.height * 0.6),
      armPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width * 0.95, size.height * 0.6),
      armPaint,
    );

    // Draw stick legs
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.8),
      Offset(size.width * 0.35, size.height * 0.95),
      armPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.8),
      Offset(size.width * 0.65, size.height * 0.95),
      armPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for dumbbell
class DumbbellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF4FC3F7)
          ..style = PaintingStyle.fill;

    // Draw dumbbell weights
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.5), 8, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.5), 8, paint);

    // Draw dumbbell bar
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.4,
        height: 4,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
