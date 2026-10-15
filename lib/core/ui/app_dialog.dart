import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';

/// Reusable modal dialog scaffold enforcing consistent animations,
/// header gradient banner, mascot positioning, and theme tokens.
class AppDialogShell extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? mascotAssetPath;
  final Widget child;
  final Widget? bottomAction;
  final double maxWidth;
  final double? maxHeight;

  const AppDialogShell({
    super.key,
    required this.title,
    required this.subtitle,
    this.mascotAssetPath,
    required this.child,
    this.bottomAction,
    this.maxWidth = 400,
    this.maxHeight,
  });

  @override
  State<AppDialogShell> createState() => _AppDialogShellState();
}

class _AppDialogShellState extends State<AppDialogShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth,
              maxHeight: widget.maxHeight ?? double.infinity,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header Banner ──
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: recoveryTheme.streakGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 24, 100, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: recoveryTheme.streakCardForeground,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: recoveryTheme.streakCardForeground
                                    .withOpacity(0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.mascotAssetPath != null)
                        Positioned(
                          right: -5,
                          bottom: -20,
                          child: Image.asset(
                            widget.mascotAssetPath!,
                            width: 110,
                            fit: BoxFit.contain,
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Content ──
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                    child: widget.child,
                  ),
                ),

                // ── Bottom Action ──
                if (widget.bottomAction != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                    child: widget.bottomAction!,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
