import 'package:flutter/material.dart';
import 'package:recova/core/ui/app_toast.dart';

/// Reusable validation banner and snackbar helper for authentication errors.
class AuthValidationBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const AuthValidationBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                color: colorScheme.onErrorContainer.withOpacity(0.7),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  /// Displays a floating error SnackBar styled using application theme tokens.
  static void showErrorSnackBar(BuildContext context, String message) {
    AppToast.showError(context, message);
  }
}
