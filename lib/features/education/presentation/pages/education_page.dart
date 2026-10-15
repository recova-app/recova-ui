import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/features/education/presentation/cubit/education_cubit.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/models/education_model.dart';
import 'package:recova/features/coach/presentation/pages/coach_page.dart';
import 'package:recova/features/notifications/presentation/pages/notification_page.dart';
import '../widgets/education_feature_card.dart';
import '../widgets/education_quote_card.dart';
import '../widgets/education_video_card.dart';
import 'article_page.dart';

/// Main education hub page displaying articles, video resources, and recovery insights.
class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  @override
  void initState() {
    super.initState();
    context.read<EducationCubit>().fetchEducationContents();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh:
              () => context.read<EducationCubit>().fetchEducationContents(),
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Quote Card
                const EducationQuoteCard(),
                const SizedBox(height: 26),

                // Features section
                Text(
                  'Fitur Edukasi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                EducationFeatureCard(
                  title: 'Smart Personal AI Coach',
                  subtitle: 'Dapatkan Insight untuk Keluhan atau Pertanyaanmu',
                  assetPath: 'assets/images/maskots/coach.png',
                  arrow: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoachPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                EducationFeatureCard(
                  title: 'Pahami Dampak Pornografi',
                  subtitle:
                      'Pelajari dampak pornografi pada otak dan kehidupanmu',
                  assetPath: 'assets/images/maskots/dampak.png',
                  arrow: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => const ArticlePage(
                              title: 'Pahami Dampak Pornografi',
                              category: 'Dampak pornografi',
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                EducationFeatureCard(
                  title: 'Tips & Strategi Pemulihan',
                  subtitle:
                      'Tips praktis mengatasi urge dan membangun kebiasaan baru',
                  assetPath: 'assets/images/maskots/pemulihan.png',
                  arrow: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => const ArticlePage(
                              title: 'Tips & Strategi Pemulihan',
                              category: 'Pemulihan',
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 26),

                // Video Library Section
                Text(
                  'Video Edukasi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),

                BlocBuilder<EducationCubit, EducationState>(
                  builder: (context, state) {
                    if (state is EducationLoading) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    }
                    if (state is EducationLoadFailure) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.error,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed:
                                    () =>
                                        context
                                            .read<EducationCubit>()
                                            .fetchEducationContents(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (state is EducationLoadSuccess) {
                      if (state.contents.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Belum ada konten edukasi.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Konten edukasi akan segera tersedia. Stay tuned!',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final groupedContent = <String, List<EducationContent>>{};
                      for (var content in state.contents) {
                        if (content.category == 'Dampak Pornografi' ||
                            content.category == 'Pemulihan') {
                          continue;
                        }
                        (groupedContent[content.category] ??= []).add(content);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            groupedContent.entries.map((entry) {
                              return _buildVideoCategory(
                                entry.key,
                                entry.value,
                              );
                            }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 26),

                // Today Insight
                Text(
                  'Insight Edukasi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  decoration: BoxDecoration(
                    color: recoveryTheme.accentSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tahukah kamu? Otak manusia memiliki kemampuan neuroplastisitas — artinya kamu bisa melatih ulang otakmu untuk melepaskan kebiasaan lama dan membangun jalur saraf baru yang lebih sehat.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Insight ini berdasarkan riset neurosains tentang pemulihan dari kecanduan',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCategory(String title, List<EducationContent> items) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return EducationVideoCard(content: items[index]);
            },
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
