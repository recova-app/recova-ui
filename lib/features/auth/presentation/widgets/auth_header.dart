import 'package:flutter/material.dart';

/// Reusable brand logo, title, and descriptive subtitle for auth views.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String logoAsset;
  final double logoSize;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoAsset = 'assets/images/logo.png',
    this.logoSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Image.asset(logoAsset, width: logoSize, height: logoSize),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}
