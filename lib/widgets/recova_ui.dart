import 'package:flutter/material.dart';

class RecovaTopBar extends StatelessWidget {
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;
  final IconData? leftIcon;
  final IconData? rightIcon;

  const RecovaTopBar({
    super.key,
    this.onLeftPressed,
    this.onRightPressed,
    this.leftIcon,
    this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (leftIcon != null)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(leftIcon, color: const Color(0xFF1A1A1A)),
              onPressed: onLeftPressed,
            ),
          )
        else
          const SizedBox(width: 48), // roughly icon size

        Image.asset(
          'assets/images/logo.png', // Fallback just in case
          height: 32,
          errorBuilder: (context, error, stackTrace) => const Text(
            'Recova',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E6B52),
            ),
          ),
        ),

        if (rightIcon != null)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(rightIcon, color: const Color(0xFF1A1A1A)),
              onPressed: onRightPressed,
            ),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}

class RecovaHeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final double? height;
  final double? imageWidth;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? footer;

  const RecovaHeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.height,
    this.imageWidth,
    this.contentPadding,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: height,
          padding: contentPadding,
          decoration: BoxDecoration(
            color: const Color(0xFF0E6B52),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (imagePath.isNotEmpty)
                Image.asset(
                  imagePath,
                  width: imageWidth,
                  fit: BoxFit.contain,
                ),
            ],
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: 16),
          footer!,
        ],
      ],
    );
  }
}

class RecovaFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String assetPath;
  final Color backgroundColor;
  final Color iconBackground;
  final Widget? trailing;
  final VoidCallback? onTap;

  const RecovaFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.backgroundColor,
    required this.iconBackground,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Image.asset(assetPath, width: 24, height: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5A6268),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
