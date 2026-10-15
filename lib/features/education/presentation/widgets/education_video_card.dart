import 'package:flutter/material.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/models/education_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Horizontal video card displaying external education resource links.
class EducationVideoCard extends StatelessWidget {
  final EducationContent content;

  const EducationVideoCard({super.key, required this.content});

  Future<void> _launchURL(String urlString) async {
    final Uri? url = Uri.tryParse(urlString);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark
            ? context.recoveryTheme.accentSurface
            : context.recoveryTheme.accentSurfaceSubtle;

    return GestureDetector(
      onTap: () => _launchURL(content.url),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                content.thumbnailUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 110,
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: colorScheme.onSurfaceVariant,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Text(
                content.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
