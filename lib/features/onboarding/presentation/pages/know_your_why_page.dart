import 'package:flutter/material.dart';
import 'package:recova/core/theme/app_theme.dart';
import 'package:recova/services/onboarding_state.dart';
import '../widgets/onboarding_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.large),
                SizedBox(
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
                Text(
                  'Tuliskan SATU alasan mengapa kamu memilih untuk berhenti menonton pornografi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    fontFamily: 'Inter',
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.small),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.5),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      height: 1.4,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tulis alasanmu di sini...',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                    onChanged: (_) => _updateButtonState(),
                  ),
                ),
                const SizedBox(height: AppSpacing.large * 2),
                OnboardingButton(
                  text: 'Simpan alasan saya',
                  isEnabled: _isButtonEnabled,
                  onPressed: _saveWhy,
                ),
                const SizedBox(height: AppSpacing.medium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
