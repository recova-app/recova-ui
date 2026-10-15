import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

class CommunityHeroBanner extends StatelessWidget {
  const CommunityHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final recoveryTheme = context.recoveryTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 172,
      decoration: BoxDecoration(
        color: recoveryTheme.streakCardBackground,
        gradient: recoveryTheme.streakGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 18,
            top: 24,
            right: 135,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kamu tidak berjuang sendirian',
                  style: TextStyle(
                    color: recoveryTheme.streakCardForeground,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Dapatkan bantuan dari teman seperjuangan di komunitas, atau bantuan dari AI coach kami.',
                  style: TextStyle(
                    color: recoveryTheme.streakCardForeground.withOpacity(0.85),
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -5,
            bottom: -34,
            child: Image.asset(
              'assets/images/home/headHub.png',
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}
