import 'package:flutter/material.dart';
import 'package:recova/models/daily_content_model.dart';

class DailyMotivationCard extends StatelessWidget {
  final DailyContent? dailyContent;

  const DailyMotivationCard({super.key, this.dailyContent});

  @override
  Widget build(BuildContext context) {
    final challenge = dailyContent?.challenge;
    final hasChallenge = challenge != null && challenge.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insight Hari Ini',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF9F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dailyContent?.motivation ??
                    'Kamu sudah melakukan yang terbaik hari ini, hasil yang memuaskan datang dari hal kecil yang dilakukan secara konsisten.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              if (hasChallenge) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8),
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
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF136E4D),
                              ),
                            ),
                            if (challenge.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                challenge.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F6E4D),
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
              const Text(
                'Insight ini disesuaikan dari journal harian yang kamu tulis dan aktivitas daily check-in kamu',
                style: TextStyle(fontSize: 10, color: Color(0xFF7A7A7A)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
