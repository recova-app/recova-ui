import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

/// AI coach persona configuration with theme-aware styling.
class CoachPersona {
  final String key;
  final String title;
  final String desc;
  final String avatarPath;

  const CoachPersona({
    required this.key,
    required this.title,
    required this.desc,
    required this.avatarPath,
  });

  /// Retrieves the persona background color from the active [RecoveryTheme].
  Color backgroundColor(BuildContext context) {
    final recoveryTheme = RecoveryTheme.of(context);
    switch (key) {
      case 'friendly':
        return recoveryTheme.friendlyPersonaColor;
      case 'direct':
        return recoveryTheme.directPersonaColor;
      case 'supportive':
      default:
        return recoveryTheme.supportivePersonaColor;
    }
  }

  /// Retrieves the persona foreground text color from the active [RecoveryTheme].
  Color textColor(BuildContext context) {
    final recoveryTheme = RecoveryTheme.of(context);
    switch (key) {
      case 'friendly':
        return recoveryTheme.friendlyPersonaTextColor;
      case 'direct':
        return recoveryTheme.directPersonaTextColor;
      case 'supportive':
      default:
        return recoveryTheme.supportivePersonaTextColor;
    }
  }

  /// Default personas available for AI coach interaction.
  static const List<CoachPersona> defaultPersonas = [
    CoachPersona(
      key: 'supportive',
      title: 'Supportive Billy',
      desc:
          'Pendamping penuh empati yang siap mendengarkan tanpa menghakimi dan memberikan afirmasi positif saat Anda merasa down.',
      avatarPath: 'assets/images/home/supportiveBilly.png',
    ),
    CoachPersona(
      key: 'friendly',
      title: 'Friendly Billy',
      desc:
          'Sahabat kasual dan santai yang siap diajak ngobrol tentang apa saja untuk memberikan distraksi positif dari dorongan negatif.',
      avatarPath: 'assets/images/home/friendlyBilly.png',
    ),
    CoachPersona(
      key: 'direct',
      title: 'Direct Billy',
      desc:
          'Billy yang tegas dan logis yang membantu menjaga akuntabilitas Anda melalui instruksi praktis agar tetap fokus pada tujuan.',
      avatarPath: 'assets/images/home/directBilly.png',
    ),
  ];
}
