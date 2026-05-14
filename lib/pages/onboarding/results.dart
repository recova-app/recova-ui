import 'package:flutter/material.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  Map<String, dynamic>? _resultData;
  Map<String, dynamic>? _analysis;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _resultData = args;
      _analysis = args['onboarding_analysis'] as Map<String, dynamic>?;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Color _getLevelColor() {
    final level = _analysis?['level']?.toString().toLowerCase() ?? '';
    if (level.contains('high') || level.contains('tinggi') || level.contains('severe')) {
      return const Color(0xFFFF6B6B);
    } else if (level.contains('moderate') || level.contains('sedang')) {
      return const Color(0xFFFFA726);
    }
    return const Color(0xFF4CAF50);
  }

  Color _getLevelBgColor() {
    final level = _analysis?['level']?.toString().toLowerCase() ?? '';
    if (level.contains('high') || level.contains('tinggi') || level.contains('severe')) {
      return const Color(0xFFFFEBEE);
    } else if (level.contains('moderate') || level.contains('sedang')) {
      return const Color(0xFFFFF3E0);
    }
    return const Color(0xFFF1F8E9);
  }

  IconData _getLevelIcon() {
    final level = _analysis?['level']?.toString().toLowerCase() ?? '';
    if (level.contains('high') || level.contains('tinggi') || level.contains('severe')) {
      return Icons.warning_rounded;
    } else if (level.contains('moderate') || level.contains('sedang')) {
      return Icons.info_rounded;
    }
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final hasAnalysis = _analysis != null;
    final level = _analysis?['level'] ?? 'Unknown';
    final title = _analysis?['title'] ?? 'Hasil Analisis';
    final levelDescription = _analysis?['level_description'] ?? '';
    final patternAnalysis = _analysis?['pattern_analysis'] ?? '';
    final encouragement = _analysis?['encouragement'] ?? '';
    final nickname = _resultData?['nickname'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      Container(
                        width: 100,
                        height: 100,
                        child: Image.asset(
                          'assets/images/maskots/results.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Level badge
                      if (hasAnalysis) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getLevelBgColor(),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getLevelColor().withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getLevelIcon(),
                                color: _getLevelColor(),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                level,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getLevelColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Title
                      Text(
                        hasAnalysis ? title : 'Jawabanmu',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      if (hasAnalysis && levelDescription.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          levelDescription,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF555555),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      if (!hasAnalysis) ...[
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              height: 1.2,
                            ),
                            children: [
                              TextSpan(text: 'Mengindikasikan kamu memiliki '),
                              TextSpan(
                                text: 'ketergantungan yang tinggi',
                                style: TextStyle(color: Color(0xFFFF6B6B)),
                              ),
                              TextSpan(text: ' terhadap '),
                              TextSpan(
                                text: 'pornografi',
                                style: TextStyle(color: Color(0xFFFF6B6B)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Disclaimer
                      Text(
                        'ini Hanya indikasi*',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF777777),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Information Cards
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (hasAnalysis) ...[
                                // Pattern Analysis card
                                if (patternAnalysis.isNotEmpty)
                                  _buildInfoCard(
                                    'Analisis Pola',
                                    patternAnalysis,
                                    Icons.psychology_rounded,
                                  ),
                                if (patternAnalysis.isNotEmpty)
                                  const SizedBox(height: 12),

                                // Encouragement card
                                if (encouragement.isNotEmpty)
                                  _buildInfoCard(
                                    'Semangat Untukmu ${nickname.isNotEmpty ? ', $nickname' : ''}',
                                    encouragement,
                                    Icons.favorite_rounded,
                                  ),
                              ] else ...[
                                // Fallback static cards
                                _buildInfoCard(
                                  'Kamu Menjadi ketergantungan dengan pornografi',
                                  'Jawabanmu menunjukkan adanya kecenderungan tinggi terhadap ketergantungan pornografi. Hal ini bisa membuatmu sulit mengendalikan diri, merasa gelisah ketika tidak mengakses, serta mengganggu fokus belajar, pekerjaan, dan hubungan sosial.',
                                  Icons.info_rounded,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoCard(
                                  'Indikasi ketergantungan pornografi terdeteksi',
                                  'Kecenderungan ini dapat mempengaruhi fungsi otak, mengurangi motivasi, dan menimbulkan kesulitan dalam mengontrol dorongan. Dampaknya bisa muncul pada kualitas belajar, pekerjaan, hingga hubungan personal.',
                                  Icons.psychology_rounded,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoCard(
                                  'Kamu punya tantangan dengan pornografi',
                                  'Hasil ini tidak mendefinisikan siapa dirimu, tapi menunjukkan area yang bisa kamu perbaiki. Dengan kesehatan dan dukungan yang tepat, kamu belajar mengelolah.',
                                  Icons.favorite_rounded,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/benefits');
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

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(
            color: Color(0xFF4CAF50),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF555555),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
