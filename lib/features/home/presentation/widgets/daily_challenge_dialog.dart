import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/core/ui/app_dialog.dart';
import 'package:recova/models/daily_content_model.dart';
import 'package:recova/services/api_service.dart';

class DailyChallengeDialog extends StatefulWidget {
  final DailyChallenge? challenge;

  const DailyChallengeDialog({super.key, this.challenge});

  @override
  State<DailyChallengeDialog> createState() => _DailyChallengeDialogState();
}

class _DailyChallengeDialogState extends State<DailyChallengeDialog> {
  DailyChallenge? _challenge;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _challenge = widget.challenge;
    if (_challenge == null || _challenge!.isEmpty) {
      _fetchChallenge();
    }
  }

  Future<void> _fetchChallenge() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final content = await ApiService.getDailyContent();
      if (mounted) {
        setState(() {
          _challenge = content.challenge;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat tantangan. Coba lagi.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogShell(
      title: 'Daily Activity\nChallenge',
      subtitle: 'Selesaikan tantangan hari ini!',
      mascotAssetPath: 'assets/images/maskots/activity.png',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Memuat tantangan...',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 36,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _fetchChallenge,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            ),
          ],
        ),
      );
    }

    if (_challenge == null || _challenge!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: recoveryTheme.accentSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: recoveryTheme.cleanStatusColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada tantangan hari ini',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cek lagi nanti ya!',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: recoveryTheme.accentSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: recoveryTheme.cleanStatusColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _challenge!.title.isNotEmpty
                          ? _challenge!.title
                          : 'Tantangan Hari Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              if (_challenge!.description.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _challenge!.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Text('💡 ', style: TextStyle(fontSize: 14)),
            Expanded(
              child: Text(
                'Tantangan ini dirancang untuk membantumu tetap produktif dan fokus.',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
