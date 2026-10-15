import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/features/education/presentation/cubit/education_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/article_card.dart';

/// Article listing page categorized by recovery topic.
class ArticlePage extends StatefulWidget {
  final String title;
  final String category;

  const ArticlePage({super.key, required this.title, required this.category});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  void initState() {
    super.initState();
    context.read<EducationCubit>().fetchEducationContents();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri? url = Uri.tryParse(urlString);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh:
              () => context.read<EducationCubit>().fetchEducationContents(),
          color: colorScheme.primary,
          child: BlocBuilder<EducationCubit, EducationState>(
            builder: (context, state) {
              if (state is EducationLoading) {
                return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                );
              }

              if (state is EducationLoadFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                );
              }

              if (state is EducationLoadSuccess) {
                final articles =
                    state.contents.where((content) {
                      return content.category.toLowerCase() ==
                          widget.category.toLowerCase();
                    }).toList();

                if (articles.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Belum ada artikel.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Artikel edukasi akan segera tersedia. Stay tuned!',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return ArticleCard(
                      title: article.title,
                      subtitle: article.description,
                      tag: article.category,
                      readTime: '3 min read',
                      onTap: () => _launchURL(article.url),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
