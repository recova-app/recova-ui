import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_colors.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/core/theme/recovery_theme.dart';
import '../widgets/onboarding_button.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage>
    with TickerProviderStateMixin {
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
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

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

  Color _getLevelColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final recoveryTheme = Theme.of(context).extension<RecoveryTheme>();
    final level = _analysis?['level']?.toString().toLowerCase() ?? '';
    if (level.contains('high') ||
        level.contains('tinggi') ||
        level.contains('severe')) {
      return colorScheme.error;
    } else if (level.contains('moderate') || level.contains('sedang')) {
      return recoveryTheme?.warningStatusColor ?? AppColors.warning;
    }
    return colorScheme.primary;
  }

  Color _getLevelBgColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final recoveryTheme = Theme.of(context).extension<RecoveryTheme>();
    final level = _analysis?['level']?.toString().toLowerCase() ?? '';
    if (level.contains('high') ||
        level.contains('tinggi') ||
        level.contains('severe')) {
      return colorScheme.errorContainer.withOpacity(0.5);
    } else if (level.contains('moderate') || level.contains('sedang')) {
      return recoveryTheme?.warningStatusBackground ?? AppColors.warningLight;
    }
    return colorScheme.primaryContainer.withOpacity(0.5);
  }

  IconData _getLevelIcon() {
    final level = _analysis?['level']?.toString().toLowerCase() ?? '';
    if (level.contains('high') ||
        level.contains('tinggi') ||
        level.contains('severe')) {
      return Icons.warning_rounded;
    } else if (level.contains('moderate') || level.contains('sedang')) {
      return Icons.info_rounded;
    }
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasAnalysis = _analysis != null;
    final level = _analysis?['level'] ?? 'Unknown';
    final title = _analysis?['title'] ?? 'Hasil Analisis';
    final levelDescription = _analysis?['level_description'] ?? '';
    final patternAnalysis = _analysis?['pattern_analysis'] ?? '';
    final encouragement = _analysis?['encouragement'] ?? '';
    final nickname = _resultData?['nickname'] ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 20,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Image.asset(
                        'assets/images/maskots/results.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (hasAnalysis) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getLevelBgColor(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getLevelIcon(),
                                color: _getLevelColor(context),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                level.toString(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getLevelColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        hasAnalysis ? title : 'Jawabanmu',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (hasAnalysis && levelDescription.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          levelDescription,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (!hasAnalysis) ...[
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              height: 1.2,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Mengindikasikan kamu memiliki ',
                              ),
                              TextSpan(
                                text: 'ketergantungan yang tinggi',
                                style: TextStyle(color: colorScheme.error),
                              ),
                              const TextSpan(text: ' terhadap '),
                              TextSpan(
                                text: 'pornografi',
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'ini Hanya indikasi*',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (hasAnalysis) ...[
                                if (patternAnalysis.isNotEmpty)
                                  _buildInfoCard(
                                    context,
                                    'Analisis Pola',
                                    patternAnalysis,
                                    Icons.psychology_rounded,
                                  ),
                                if (patternAnalysis.isNotEmpty)
                                  const SizedBox(height: 12),
                                if (encouragement.isNotEmpty)
                                  _buildInfoCard(
                                    context,
                                    'Semangat Untukmu ${nickname.isNotEmpty ? ', $nickname' : ''}',
                                    encouragement,
                                    Icons.favorite_rounded,
                                  ),
                              ] else ...[
                                _buildInfoCard(
                                  context,
                                  'Kamu Menjadi ketergantungan dengan pornografi',
                                  'Jawabanmu menunjukkan adanya kecenderungan tinggi terhadap ketergantungan pornografi. Hal ini bisa membuatmu sulit mengendalikan diri, merasa gelisah ketika tidak mengakses, serta mengganggu fokus belajar, pekerjaan, dan hubungan sosial.',
                                  Icons.info_rounded,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoCard(
                                  context,
                                  'Indikasi ketergantungan pornografi terdeteksi',
                                  'Kecenderungan ini dapat mempengaruhi fungsi otak, mengurangi motivasi, dan menimbulkan kesulitan dalam mengontrol dorongan. Dampaknya bisa muncul pada kualitas belajar, pekerjaan, hingga hubungan personal.',
                                  Icons.psychology_rounded,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoCard(
                                  context,
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
                      OnboardingButton(
                        text: 'Selanjutnya',
                        onPressed: () {
                          Navigator.pushNamed(context, '/benefits');
                        },
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

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
