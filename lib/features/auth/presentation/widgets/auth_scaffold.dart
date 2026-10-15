import 'package:flutter/material.dart';

/// Reusable layout scaffold for authentication screens with bottom illustration.
class AuthScaffold extends StatelessWidget {
  final Widget body;
  final String backgroundAsset;

  const AuthScaffold({
    super.key,
    required this.body,
    this.backgroundAsset = 'assets/images/billy-on-splash.png',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              backgroundAsset,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          SafeArea(bottom: false, child: body),
        ],
      ),
    );
  }
}
