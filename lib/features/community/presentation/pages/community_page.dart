import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/features/community/presentation/cubit/community_cubit.dart';
import 'package:recova/features/community/presentation/pages/create_post_page.dart';
import 'package:recova/features/community/presentation/widgets/community_comments_sheet.dart';
import 'package:recova/features/community/presentation/widgets/community_filter_chips.dart';
import 'package:recova/features/community/presentation/widgets/community_post_card.dart';
import 'package:recova/models/post_model.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _selectedFilter = 'Nasihat';
  final List<String> _filters = const ['Nasihat', 'Bantuan', 'Motivasi'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityCubit>().fetchPosts();
    });
  }

  Future<void> _openCreatePost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: context.read<CommunityCubit>(),
              child: const CreatePostPage(),
            ),
      ),
    );
    if (!mounted) return;
    await context.read<CommunityCubit>().fetchPosts();
  }

  Future<void> _openCommentsSheet(Post post) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CommunityCommentsSheet(post: post),
    );
    if (!mounted) return;
    await context.read<CommunityCubit>().fetchPosts();
  }

  bool _categoryMatches(String postCategory, String selectedFilter) {
    String normalize(String value) {
      final v = value.toLowerCase().trim();
      if (v == 'saran') return 'nasihat';
      if (v == 'advice') return 'nasihat';
      if (v == 'help') return 'bantuan';
      if (v == 'motivation') return 'motivasi';
      return v;
    }

    final p = normalize(postCategory);
    final f = normalize(selectedFilter);
    return p == f;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Komunitas',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 24),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: () => context.read<CommunityCubit>().fetchPosts(),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CommunityFilterChips(
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterSelected: (newFilter) {
                setState(() {
                  _selectedFilter = newFilter;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<CommunityCubit, CommunityState>(
                builder: (context, state) {
                  if (state is CommunityLoading || state is CommunityInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CommunityLoadFailure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.error,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed:
                                  () =>
                                      context
                                          .read<CommunityCubit>()
                                          .fetchPosts(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final loaded = state as CommunityLoadSuccess;
                  final posts =
                      loaded.posts
                          .where(
                            (p) =>
                                _categoryMatches(p.category, _selectedFilter),
                          )
                          .toList();

                  if (posts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: recoveryTheme.accentSurface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.forum_outlined,
                                size: 30,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Belum ada postingan di kategori ini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Yuk jadi yang pertama berbagi cerita atau dukungan di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: _openCreatePost,
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Tulis Postingan'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 110),
                    itemCount: posts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return CommunityPostCard(
                        post: post,
                        onLike:
                            () => context.read<CommunityCubit>().toggleLike(
                              post.id,
                            ),
                        onComments: () => _openCommentsSheet(post),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePost,
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, size: 34, color: Colors.white),
      ),
    );
  }
}
