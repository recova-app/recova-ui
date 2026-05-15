import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Learning5 extends StatelessWidget {
  const Learning5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cute Brain Character with Refresh Symbol
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Container(
                      width: 220,
                      height: 220,
                      child: Image.asset(
                        'assets/images/maskots/learning-5.png',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // Main Title
                    Text(
                      'Wajar jika kamu merasa terjebak oleh pornografi. Tapi kamu tidak benar-benar terjebak.',
                      textAlign: TextAlign.center,
                      style: AppText.h2.copyWith(
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.large),

                    // Subtitle
                    Text(
                      'Otakmu bisa berubah dan menyesuaikan kembali.',
                      textAlign: TextAlign.center,
                      style: AppText.h2.copyWith(
                        color: AppTheme.textGrey,
                        height: 1.4,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Action Area
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/question-1',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: const Text(
                          'Selanjutnya',
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
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for cute brain character
class CuteBrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Brain body (purple color)
    final brainPaint = Paint()
      ..color = const Color(0xFFB39DDB) // Light purple
      ..style = PaintingStyle.fill;

    // Brain outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF9575CD) // Medium purple
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Arms
    final armPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Legs
    final legPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw main brain shape
    final brainPath = Path();

    // Brain outline (rounded, bulbous shape)
    brainPath.moveTo(size.width * 0.3, size.height * 0.2);
    brainPath.quadraticBezierTo(
      size.width * 0.1, size.height * 0.1,
      size.width * 0.2, size.height * 0.35,
    );
    brainPath.quadraticBezierTo(
      size.width * 0.15, size.height * 0.5,
      size.width * 0.25, size.height * 0.65,
    );
    brainPath.quadraticBezierTo(
      size.width * 0.35, size.height * 0.75,
      size.width * 0.5, size.height * 0.7,
    );
    brainPath.quadraticBezierTo(
      size.width * 0.65, size.height * 0.75,
      size.width * 0.75, size.height * 0.65,
    );
    brainPath.quadraticBezierTo(
      size.width * 0.85, size.height * 0.5,
      size.width * 0.8, size.height * 0.35,
    );
    brainPath.quadraticBezierTo(
      size.width * 0.9, size.height * 0.1,
      size.width * 0.7, size.height * 0.2,
    );
    brainPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.05,
      size.width * 0.3, size.height * 0.2,
    );
    brainPath.close();

    canvas.drawPath(brainPath, brainPaint);
    canvas.drawPath(brainPath, outlinePaint);

    // Draw brain texture lines
    final texturePaint = Paint()
      ..color = const Color(0xFF9575CD)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Left hemisphere lines
    final leftTexture = Path();
    leftTexture.moveTo(size.width * 0.25, size.height * 0.3);
    leftTexture.quadraticBezierTo(
      size.width * 0.2, size.height * 0.4,
      size.width * 0.3, size.height * 0.5,
    );
    leftTexture.moveTo(size.width * 0.35, size.height * 0.35);
    leftTexture.quadraticBezierTo(
      size.width * 0.3, size.height * 0.45,
      size.width * 0.4, size.height * 0.55,
    );

    // Right hemisphere lines
    leftTexture.moveTo(size.width * 0.75, size.height * 0.3);
    leftTexture.quadraticBezierTo(
      size.width * 0.8, size.height * 0.4,
      size.width * 0.7, size.height * 0.5,
    );
    leftTexture.moveTo(size.width * 0.65, size.height * 0.35);
    leftTexture.quadraticBezierTo(
      size.width * 0.7, size.height * 0.45,
      size.width * 0.6, size.height * 0.55,
    );

    // Center line
    leftTexture.moveTo(size.width * 0.5, size.height * 0.25);
    leftTexture.quadraticBezierTo(
      size.width * 0.48, size.height * 0.4,
      size.width * 0.5, size.height * 0.6,
    );

    canvas.drawPath(leftTexture, texturePaint);

    // Draw eyes
    final leftEye = Offset(size.width * 0.4, size.height * 0.4);
    final rightEye = Offset(size.width * 0.6, size.height * 0.4);

    canvas.drawCircle(leftEye, 4, eyePaint);
    canvas.drawCircle(rightEye, 4, eyePaint);

    // Draw cute mouth (small rectangle with rounded corners)
    final mouthRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.52),
        width: 8,
        height: 4,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(mouthRect, mouthPaint);

    // Draw arms
    // Left arm
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.55),
      Offset(size.width * 0.05, size.height * 0.65),
      armPaint,
    );

    // Right arm
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.55),
      Offset(size.width * 0.95, size.height * 0.65),
      armPaint,
    );

    // Draw legs
    // Left leg
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 0.9),
      legPaint,
    );

    // Right leg
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.7),
      Offset(size.width * 0.7, size.height * 0.9),
      legPaint,
    );

    // Draw feet (small circles)
    final footPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.9), 3, footPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.9), 3, footPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
