import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

enum ToastType { success, error, warning, info }

/// Centralized notification toast utility enforcing consistent floating
/// pill styling, icons, and theme colors across the application.
class AppToast {
  const AppToast._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, ToastType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, ToastType.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, ToastType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, ToastType.info);
  }

  static void _show(BuildContext context, String message, ToastType type) {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;

    final Color bgColor;
    final Color foregroundColor;
    final IconData icon;

    switch (type) {
      case ToastType.success:
        bgColor = recoveryTheme.cleanStatusColor;
        foregroundColor = Colors.white;
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.error:
        bgColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        icon = Icons.error_outline_rounded;
        break;
      case ToastType.warning:
        bgColor = recoveryTheme.warningStatusColor;
        foregroundColor = Colors.white;
        icon = Icons.warning_amber_rounded;
        break;
      case ToastType.info:
        bgColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        icon = Icons.info_outline_rounded;
        break;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 3,
        backgroundColor: bgColor,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
