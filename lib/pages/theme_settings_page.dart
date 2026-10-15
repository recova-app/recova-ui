import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            // Dark Mode Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Row(
                  children: [
                    Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dark Mode', style: AppText.body),
                          Text(
                            'Toggle between light and dark theme',
                            style: AppText.small,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isDarkMode = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.medium),

            // Preview Colors
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Color Preview', style: AppText.h2),
                    const SizedBox(height: AppSpacing.medium),

                    // Color Rows
                    _buildColorRow('Primary', AppTheme.primary),
                    _buildColorRow('Secondary', AppTheme.secondary),
                    _buildColorRow('Success', AppTheme.success),
                    _buildColorRow('Error', AppTheme.error),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Text(name, style: AppText.body),
        ],
      ),
    );
  }
}
