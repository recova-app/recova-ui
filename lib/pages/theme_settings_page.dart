import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/theme_cubit.dart';
import '../theme/app_theme.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  ThemeMode _fallbackMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    ThemeCubit? themeCubit;
    try {
      themeCubit = context.watch<ThemeCubit>();
    } catch (_) {
      themeCubit = null;
    }

    final currentMode =
        themeCubit != null ? themeCubit.state.themeMode : _fallbackMode;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isEffectiveDark =
        currentMode == ThemeMode.dark ||
        (currentMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    final colorScheme = Theme.of(context).colorScheme;
    final recoveryTheme = context.recoveryTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            // Theme Mode Segmented Control
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tampilan Aplikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pilih tema terang, gelap, atau mengikuti sistem perangkat.',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('Sistem'),
                          icon: Icon(Icons.brightness_auto, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Terang'),
                          icon: Icon(Icons.light_mode, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Gelap'),
                          icon: Icon(Icons.dark_mode, size: 18),
                        ),
                      ],
                      selected: {currentMode},
                      onSelectionChanged: (Set<ThemeMode> selection) {
                        final selected = selection.first;
                        if (themeCubit != null) {
                          themeCubit.setThemeMode(selected);
                        } else {
                          setState(() {
                            _fallbackMode = selected;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.medium),

            // Quick Dark Mode Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Row(
                  children: [
                    Icon(
                      isEffectiveDark ? Icons.dark_mode : Icons.light_mode,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            currentMode == ThemeMode.system
                                ? 'Mengikuti sistem (${isEffectiveDark ? "Gelap" : "Terang"})'
                                : (isEffectiveDark
                                    ? 'Tema gelap aktif'
                                    : 'Tema terang aktif'),
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isEffectiveDark,
                      onChanged: (value) {
                        final targetMode =
                            value ? ThemeMode.dark : ThemeMode.light;
                        if (themeCubit != null) {
                          themeCubit.setThemeMode(targetMode);
                        } else {
                          setState(() {
                            _fallbackMode = targetMode;
                          });
                        }
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
                    Text(
                      'Color Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),

                    // Color Rows reflecting active runtime tokens
                    _buildColorRow(
                      'Primary',
                      colorScheme.primary,
                      colorScheme.onSurface,
                    ),
                    _buildColorRow(
                      'Secondary',
                      colorScheme.secondary,
                      colorScheme.onSurface,
                    ),
                    _buildColorRow(
                      'Success (Clean)',
                      recoveryTheme.cleanStatusColor,
                      colorScheme.onSurface,
                    ),
                    _buildColorRow(
                      'Error (Relapse)',
                      colorScheme.error,
                      colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(String name, Color color, Color textColor) {
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
          Text(
            name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
