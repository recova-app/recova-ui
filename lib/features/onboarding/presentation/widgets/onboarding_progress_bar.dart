import 'package:flutter/material.dart';

/// Reusable progress bar for onboarding question flows.
///
/// Visualizes the user's progress through the diagnostic questionnaire
/// referencing [ThemeData.colorScheme] tokens.
class OnboardingProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final double borderRadius;

  const OnboardingProgressBar({
    super.key,
    required this.progress,
    this.height = 16,
    this.borderRadius = 8,
  }) : assert(
         progress >= 0.0 && progress <= 1.0,
         'Progress must be between 0.0 and 1.0',
       );

  /// Creates a progress bar computed from discrete step counts.
  factory OnboardingProgressBar.step({
    Key? key,
    required int currentStep,
    required int totalSteps,
    double height = 16,
    double borderRadius = 8,
  }) {
    final clampedStep = currentStep.clamp(0, totalSteps);
    final ratio = totalSteps > 0 ? (clampedStep / totalSteps) : 0.0;
    return OnboardingProgressBar(
      key: key,
      progress: ratio.clamp(0.0, 1.0),
      height: height,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      ),
    );
  }
}
