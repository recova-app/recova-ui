import 'package:flutter/material.dart';

/// Standardized color tokens and semantic ramps for Recova.
///
/// Contrast meets WCAG AA standards (minimum 4.5:1 for normal text,
/// 3.0:1 for large text and UI components).
abstract class AppColors {
  // ── Brand Primary Ramp (Forest Green) ───────────────────────────
  static const Color primary = Color(0xFF136E4D);
  static const Color primaryLight = Color(0xFF22A06B);
  static const Color primaryLighter = Color(0xFF38B768);
  static const Color primaryDark = Color(0xFF0B5038);

  static const Color primaryContainerLight = Color(0xFFEAF9F1);
  static const Color onPrimaryContainerLight = Color(0xFF0B5038);

  static const Color primaryContainerDark = Color(0xFF1B4D3E);
  static const Color onPrimaryContainerDark = Color(0xFFEAF9F1);

  // ── Legacy Primary (For backwards compatibility with early mockups) ─
  static const Color legacyPrimary = Color(0xFF4CAF50);

  // ── Secondary Ramp (Coral / Accent) ─────────────────────────────
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color secondaryLight = Color(0xFFFF8E8E);
  static const Color secondaryDark = Color(0xFFD9534F);

  static const Color secondaryContainerLight = Color(0xFFFFE8E8);
  static const Color onSecondaryContainerLight = Color(0xFF781E1E);

  static const Color secondaryContainerDark = Color(0xFF5A1C1C);
  static const Color onSecondaryContainerDark = Color(0xFFFFDADA);

  // ── Tertiary Ramp (Teal / Ocean) ────────────────────────────────
  static const Color tertiary = Color(0xFF0C7A57);
  static const Color tertiaryLight = Color(0xFF3B82F6);
  static const Color tertiaryDark = Color(0xFF08543B);

  // ── Neutral Surfaces (Light) ───────────────────────────────────
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF3F4F6);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFE5E7EB);

  // ── Neutral Surfaces (Dark) ────────────────────────────────────
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariantDark = Color(0xFF374151);
  static const Color cardDark = Color(0xFF1F2937);
  static const Color borderDark = Color(0xFF374151);
  static const Color dividerDark = Color(0xFF374151);

  // ── Text Ramps (Light Mode - WCAG AA/AAA compliant against white) ──
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF4B5563);
  static const Color textMutedLight = Color(0xFF6B7280);
  static const Color textDisabledLight = Color(0xFF9CA3AF);

  // ── Text Ramps (Dark Mode - WCAG AA/AAA compliant against dark surface) ──
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textMutedDark = Color(0xFF9CA3AF);
  static const Color textDisabledDark = Color(0xFF6B7280);

  // ── Status Tokens ──────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);

  // ── Standard Gradients ─────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient legacyGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF0E523A), Color(0xFF1A7F54)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
