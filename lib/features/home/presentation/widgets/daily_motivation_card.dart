import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/models/daily_content_model.dart';

class DailyMotivationCard extends StatelessWidget {
  final DailyContent? dailyContent;

  const DailyMotivationCard({super.key, this.dailyContent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;
    final challenge = dailyContent?.challenge;
    final hasChallenge = challenge != null && challenge.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insight Hari Ini',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          decoration: BoxDecoration(
            color: recoveryTheme.accentSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dailyContent?.motivation ??
                    'Kamu sudah melakukan yang terbaik hari ini, hasil yang memuaskan datang dari hal kecil yang dilakukan secara konsisten.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  height: 1.25,
                ),
              ),
              if (hasChallenge) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: recoveryTheme.cleanStatusBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🎯 ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.title.isNotEmpty
                                  ? challenge.title
                                  : 'Tantangan Hari Ini',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            if (challenge.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                challenge.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: recoveryTheme.cleanStatusColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Insight ini disesuaikan dari journal harian yang kamu tulis dan aktivitas daily check-in kamu',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
