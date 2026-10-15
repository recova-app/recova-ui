import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeShowcasePage extends StatelessWidget {
  const ThemeShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Showcase'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/theme-settings');
            },
            icon: const Icon(Icons.palette),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typography
            Text('Typography', style: AppText.h1),
            const SizedBox(height: AppSpacing.medium),
            Text('This is H1 text', style: AppText.h1),
            Text('This is H2 text', style: AppText.h2),
            Text('This is body text', style: AppText.body),
            Text('This is small text', style: AppText.small),

            const SizedBox(height: AppSpacing.large),

            // Buttons
            Text('Buttons', style: AppText.h1),
            const SizedBox(height: AppSpacing.medium),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Primary Button'),
              ),
            ),

            const SizedBox(height: AppSpacing.small),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined Button'),
              ),
            ),

            const SizedBox(height: AppSpacing.small),

            // Gradient Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: const Text('Gradient Button'),
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            // Colors
            Text('Colors', style: AppText.h1),
            const SizedBox(height: AppSpacing.medium),

            _buildColorCard('Primary', AppTheme.primary),
            _buildColorCard('Secondary', AppTheme.secondary),
            _buildColorCard('Success', AppTheme.success),
            _buildColorCard('Warning', AppTheme.warning),
            _buildColorCard('Error', AppTheme.error),

            const SizedBox(height: AppSpacing.large),

            // Form Elements
            Text('Form Elements', style: AppText.h1),
            const SizedBox(height: AppSpacing.medium),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),

            const SizedBox(height: AppSpacing.medium),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCard(String name, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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
          Text(name, style: AppText.body.copyWith(color: color)),
        ],
      ),
    );
  }
}
