import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Custom theme extension for domain-specific recovery UI tokens.
///
/// Encapsulates streak gradients, persona badge styles, and recovery status
/// indicators that lie outside standard Material 3 design tokens.
@immutable
class RecoveryTheme extends ThemeExtension<RecoveryTheme> {
  // ── Streak & Challenge Tokens ─────────────────────────────────
  final LinearGradient streakGradient;
  final Color streakCardBackground;
  final Color streakCardForeground;
  final Color streakBadgeBackground;
  final Color streakBadgeForeground;

  // ── Persona Badge Tokens ──────────────────────────────────────
  final Color supportivePersonaColor;
  final Color supportivePersonaTextColor;
  final Color friendlyPersonaColor;
  final Color friendlyPersonaTextColor;
  final Color directPersonaColor;
  final Color directPersonaTextColor;

  // ── Recovery Status Indicators ────────────────────────────────
  final Color cleanStatusColor;
  final Color cleanStatusBackground;
  final Color relapseStatusColor;
  final Color relapseStatusBackground;
  final Color warningStatusColor;
  final Color warningStatusBackground;
  final Color progressBackground;
  final Color accentSurface;
  final Color accentSurfaceSubtle;

  const RecoveryTheme({
    required this.streakGradient,
    required this.streakCardBackground,
    required this.streakCardForeground,
    required this.streakBadgeBackground,
    required this.streakBadgeForeground,
    required this.supportivePersonaColor,
    required this.supportivePersonaTextColor,
    required this.friendlyPersonaColor,
    required this.friendlyPersonaTextColor,
    required this.directPersonaColor,
    required this.directPersonaTextColor,
    required this.cleanStatusColor,
    required this.cleanStatusBackground,
    required this.relapseStatusColor,
    required this.relapseStatusBackground,
    required this.warningStatusColor,
    required this.warningStatusBackground,
    required this.progressBackground,
    required this.accentSurface,
    required this.accentSurfaceSubtle,
  });

  /// Light theme preset for [RecoveryTheme].
  static const RecoveryTheme light = RecoveryTheme(
    streakGradient: AppColors.primaryGradient,
    streakCardBackground: AppColors.primary,
    streakCardForeground: Colors.white,
    streakBadgeBackground: Color(0xFFEAF9F1),
    streakBadgeForeground: AppColors.primary,
    supportivePersonaColor: Color(0xFFE8F5E9),
    supportivePersonaTextColor: Color(0xFF1B5E20),
    friendlyPersonaColor: Color(0xFFE0F2F1),
    friendlyPersonaTextColor: Color(0xFF004D40),
    directPersonaColor: Color(0xFFFFF3E0),
    directPersonaTextColor: Color(0xFFE65100),
    cleanStatusColor: AppColors.success,
    cleanStatusBackground: AppColors.successLight,
    relapseStatusColor: AppColors.error,
    relapseStatusBackground: AppColors.errorLight,
    warningStatusColor: AppColors.warning,
    warningStatusBackground: AppColors.warningLight,
    progressBackground: Color(0xFFE5E7EB),
    accentSurface: AppColors.primaryContainerLight,
    accentSurfaceSubtle: Color(0xFFF0FDF4),
  );

  /// Dark theme preset for [RecoveryTheme].
  static const RecoveryTheme dark = RecoveryTheme(
    streakGradient: AppColors.darkPrimaryGradient,
    streakCardBackground: Color(0xFF163E2F),
    streakCardForeground: Color(0xFFEAF9F1),
    streakBadgeBackground: Color(0xFF1F4D3C),
    streakBadgeForeground: Color(0xFF81C784),
    supportivePersonaColor: Color(0xFF1B3828),
    supportivePersonaTextColor: Color(0xFF81C784),
    friendlyPersonaColor: Color(0xFF173836),
    friendlyPersonaTextColor: Color(0xFF4DB6AC),
    directPersonaColor: Color(0xFF3E2C18),
    directPersonaTextColor: Color(0xFFFFB74D),
    cleanStatusColor: Color(0xFF34D399),
    cleanStatusBackground: Color(0xFF064E3B),
    relapseStatusColor: Color(0xFFF87171),
    relapseStatusBackground: Color(0xFF450A0A),
    warningStatusColor: Color(0xFFFBBF24),
    warningStatusBackground: Color(0xFF451A03),
    progressBackground: Color(0xFF374151),
    accentSurface: AppColors.primaryContainerDark,
    accentSurfaceSubtle: Color(0xFF132A20),
  );

  /// Convenient helper to retrieve [RecoveryTheme] from [BuildContext].
  static RecoveryTheme of(BuildContext context) {
    return Theme.of(context).extension<RecoveryTheme>() ?? RecoveryTheme.light;
  }

  @override
  RecoveryTheme copyWith({
    LinearGradient? streakGradient,
    Color? streakCardBackground,
    Color? streakCardForeground,
    Color? streakBadgeBackground,
    Color? streakBadgeForeground,
    Color? supportivePersonaColor,
    Color? supportivePersonaTextColor,
    Color? friendlyPersonaColor,
    Color? friendlyPersonaTextColor,
    Color? directPersonaColor,
    Color? directPersonaTextColor,
    Color? cleanStatusColor,
    Color? cleanStatusBackground,
    Color? relapseStatusColor,
    Color? relapseStatusBackground,
    Color? warningStatusColor,
    Color? warningStatusBackground,
    Color? progressBackground,
    Color? accentSurface,
    Color? accentSurfaceSubtle,
  }) {
    return RecoveryTheme(
      streakGradient: streakGradient ?? this.streakGradient,
      streakCardBackground: streakCardBackground ?? this.streakCardBackground,
      streakCardForeground: streakCardForeground ?? this.streakCardForeground,
      streakBadgeBackground:
          streakBadgeBackground ?? this.streakBadgeBackground,
      streakBadgeForeground:
          streakBadgeForeground ?? this.streakBadgeForeground,
      supportivePersonaColor:
          supportivePersonaColor ?? this.supportivePersonaColor,
      supportivePersonaTextColor:
          supportivePersonaTextColor ?? this.supportivePersonaTextColor,
      friendlyPersonaColor: friendlyPersonaColor ?? this.friendlyPersonaColor,
      friendlyPersonaTextColor:
          friendlyPersonaTextColor ?? this.friendlyPersonaTextColor,
      directPersonaColor: directPersonaColor ?? this.directPersonaColor,
      directPersonaTextColor:
          directPersonaTextColor ?? this.directPersonaTextColor,
      cleanStatusColor: cleanStatusColor ?? this.cleanStatusColor,
      cleanStatusBackground:
          cleanStatusBackground ?? this.cleanStatusBackground,
      relapseStatusColor: relapseStatusColor ?? this.relapseStatusColor,
      relapseStatusBackground:
          relapseStatusBackground ?? this.relapseStatusBackground,
      warningStatusColor: warningStatusColor ?? this.warningStatusColor,
      warningStatusBackground:
          warningStatusBackground ?? this.warningStatusBackground,
      progressBackground: progressBackground ?? this.progressBackground,
      accentSurface: accentSurface ?? this.accentSurface,
      accentSurfaceSubtle: accentSurfaceSubtle ?? this.accentSurfaceSubtle,
    );
  }

  @override
  RecoveryTheme lerp(ThemeExtension<RecoveryTheme>? other, double t) {
    if (other is! RecoveryTheme) {
      return this;
    }

    return RecoveryTheme(
      streakGradient:
          LinearGradient.lerp(streakGradient, other.streakGradient, t) ??
          streakGradient,
      streakCardBackground:
          Color.lerp(streakCardBackground, other.streakCardBackground, t) ??
          streakCardBackground,
      streakCardForeground:
          Color.lerp(streakCardForeground, other.streakCardForeground, t) ??
          streakCardForeground,
      streakBadgeBackground:
          Color.lerp(streakBadgeBackground, other.streakBadgeBackground, t) ??
          streakBadgeBackground,
      streakBadgeForeground:
          Color.lerp(streakBadgeForeground, other.streakBadgeForeground, t) ??
          streakBadgeForeground,
      supportivePersonaColor:
          Color.lerp(supportivePersonaColor, other.supportivePersonaColor, t) ??
          supportivePersonaColor,
      supportivePersonaTextColor:
          Color.lerp(
            supportivePersonaTextColor,
            other.supportivePersonaTextColor,
            t,
          ) ??
          supportivePersonaTextColor,
      friendlyPersonaColor:
          Color.lerp(friendlyPersonaColor, other.friendlyPersonaColor, t) ??
          friendlyPersonaColor,
      friendlyPersonaTextColor:
          Color.lerp(
            friendlyPersonaTextColor,
            other.friendlyPersonaTextColor,
            t,
          ) ??
          friendlyPersonaTextColor,
      directPersonaColor:
          Color.lerp(directPersonaColor, other.directPersonaColor, t) ??
          directPersonaColor,
      directPersonaTextColor:
          Color.lerp(directPersonaTextColor, other.directPersonaTextColor, t) ??
          directPersonaTextColor,
      cleanStatusColor:
          Color.lerp(cleanStatusColor, other.cleanStatusColor, t) ??
          cleanStatusColor,
      cleanStatusBackground:
          Color.lerp(cleanStatusBackground, other.cleanStatusBackground, t) ??
          cleanStatusBackground,
      relapseStatusColor:
          Color.lerp(relapseStatusColor, other.relapseStatusColor, t) ??
          relapseStatusColor,
      relapseStatusBackground:
          Color.lerp(
            relapseStatusBackground,
            other.relapseStatusBackground,
            t,
          ) ??
          relapseStatusBackground,
      warningStatusColor:
          Color.lerp(warningStatusColor, other.warningStatusColor, t) ??
          warningStatusColor,
      warningStatusBackground:
          Color.lerp(
            warningStatusBackground,
            other.warningStatusBackground,
            t,
          ) ??
          warningStatusBackground,
      progressBackground:
          Color.lerp(progressBackground, other.progressBackground, t) ??
          progressBackground,
      accentSurface:
          Color.lerp(accentSurface, other.accentSurface, t) ?? accentSurface,
      accentSurfaceSubtle:
          Color.lerp(accentSurfaceSubtle, other.accentSurfaceSubtle, t) ??
          accentSurfaceSubtle,
    );
  }
}

/// Extension on [BuildContext] for ergonomic access to [RecoveryTheme].
extension RecoveryThemeContextExtension on BuildContext {
  RecoveryTheme get recoveryTheme => RecoveryTheme.of(this);
}
