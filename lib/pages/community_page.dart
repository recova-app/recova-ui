import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/bloc/community_cubit.dart';
import 'package:recova/models/community_comment_model.dart';
import 'package:recova/models/post_model.dart';
import 'package:recova/pages/create_post_page.dart';
import 'package:recova/services/api_service.dart';

String _maskCommunityName(String? rawName) {
  final name = (rawName ?? '').trim();
  if (name.isEmpty) return 'Anonim';

  final visibleLength = name.length >= 3 ? 3 : 1;
  final visiblePart = name.substring(0, visibleLength);
  return '$visiblePart*****';
}

String _formatCommunityTime(DateTime dateTime) {
  final localTime = dateTime.toLocal();
  final hour = localTime.hour.toString().padLeft(2, '0');
  final minute = localTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatRelativeCommunityTime(DateTime dateTime) {
  final now = DateTime.now();
  final localTime = dateTime.toLocal();
  final diff = now.difference(localTime);

  if (diff.inMinutes < 1) return 'baru saja';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}j';
  if (diff.inDays < 7) return '${diff.inDays}h';
  return _formatCommunityTime(localTime);
}

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
        builder: (_) => BlocProvider.value(
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _CommentsSheet(post: post),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Komunitas',
          style: _CommunityTypography.pageTitle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon:
              const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 24),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFD9DEE6)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<CommunityCubit>().fetchPosts(),
        child: Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final label = _filters[index];
                  final selected = _selectedFilter == label;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = label;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF0B9A63)
                            : const Color(0xFFDDE3EC),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF0B9A63)
                              : const Color(0xFFD0D7E2),
                        ),
                        boxShadow: selected
                            ? const [
                                BoxShadow(
                                  color: Color(0x220B9A63),
                                  blurRadius: 12,
                                  offset: Offset(0, 5),
                                ),
                              ]
                            : const [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.circle,
                                  size: 7, color: Colors.white),
                            ),
                          Text(
                            label,
                            style: selected
                                ? _CommunityTypography.filterSelected
                                : _CommunityTypography.filterDefault,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<CommunityCubit, CommunityState>(
                builder: (context, state) {
                  if ((state is CommunityLoading ||
                          state is CommunityInitial) &&
                      state.posts.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CommunityLoadFailure && state.posts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          state.error,
                          textAlign: TextAlign.center,
                          style: _CommunityTypography.errorText,
                        ),
                      ),
                    );
                  }

                  final posts = state.posts
                      .where(
                          (p) => _categoryMatches(p.category, _selectedFilter))
                      .toList();

                  if (posts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF7F1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.forum_outlined,
                                size: 30,
                                color: Color(0xFF0B9A63),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Belum ada postingan di kategori ini.',
                              textAlign: TextAlign.center,
                              style: _CommunityTypography.emptyText,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Yuk jadi yang pertama berbagi cerita atau dukungan di sini.',
                              textAlign: TextAlign.center,
                              style: _CommunityTypography.emptyHint,
                            ),
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: _openCreatePost,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF0B9A63),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
                      return _CommunityPostCard(
                        post: post,
                        onLike: () =>
                            context.read<CommunityCubit>().toggleLike(post.id),
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
        backgroundColor: const Color(0xFF0B9A63),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, size: 34, color: Colors.white),
      ),
    );
  }
}

class _CommunityTypography {
  const _CommunityTypography._();

  static const TextStyle pageTitle = TextStyle(
    color: Color(0xFF0F172A),
    fontWeight: FontWeight.w700,
    fontSize: 20 * 0.84,
    letterSpacing: -0.2,
  );

  static const TextStyle filterSelected = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.05,
  );

  static const TextStyle filterDefault = TextStyle(
    color: Color(0xFF4B5563),
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.05,
  );

  static const TextStyle postContent = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.55,
    color: Color(0xFF1F2937),
    letterSpacing: 0.1,
  );

  static const TextStyle userName = TextStyle(
    color: Color(0xFF4B5563),
    fontWeight: FontWeight.w500,
    fontSize: 13.5,
  );

  static const TextStyle metaCount = TextStyle(
    color: Color(0xFF6B7280),
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle errorText = TextStyle(
    color: Color(0xFF6B7280),
    height: 1.45,
    fontSize: 14,
  );

  static const TextStyle emptyText = TextStyle(
    color: Color(0xFF1F2937),
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle emptyHint = TextStyle(
    color: Color(0xFF6B7280),
    fontSize: 13.5,
    height: 1.4,
  );

  static const TextStyle commentTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );

  static const TextStyle commentAuthor = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 13,
    color: Color(0xFF1F2937),
  );

  static const TextStyle commentTime = TextStyle(
    color: Color(0xFF9AA3B2),
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle commentBody = TextStyle(
    color: Color(0xFF1F2937),
    height: 1.42,
    fontSize: 13.5,
  );

  static const TextStyle commentReply = TextStyle(
    color: Color(0xFF0B9A63),
    fontWeight: FontWeight.w600,
    fontSize: 12.5,
  );
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.onLike,
    required this.onComments,
  });

  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComments;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EAF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: _CommunityTypography.postContent,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                _maskCommunityName(post.username),
                style: _CommunityTypography.userName,
              ),
              const SizedBox(width: 8),
              Text(
                '• ${_formatRelativeCommunityTime(post.createdAt)}',
                style: _CommunityTypography.metaCount,
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE7F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      '${post.userStreak ?? 0}',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.local_fire_department,
                        size: 12, color: Color(0xFFF59E0B)),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _CommunityActionButton(
                onTap: onComments,
                count: post.commentCount,
                icon: Icons.chat_bubble_outline,
              ),
              const SizedBox(width: 8),
              _CommunityActionButton(
                onTap: onLike,
                count: post.likeCount,
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                iconColor:
                    post.isLiked ? Colors.redAccent : const Color(0xFF6B7280),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _CommunityActionButton extends StatelessWidget {
  const _CommunityActionButton({
    required this.onTap,
    required this.count,
    required this.icon,
    this.iconColor = const Color(0xFF6B7280),
  });

  final VoidCallback onTap;
  final int count;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 36),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE1E6EE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: _CommunityTypography.metaCount,
            ),
            const SizedBox(width: 5),
            Icon(icon, size: 20, color: iconColor),
          ],
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.post});

  final Post post;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<CommunityComment> _comments = const [];
  bool _loading = true;
  bool _sending = false;
  CommunityComment? _replyTarget;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _loading = true;
    });
    try {
      final data = await ApiService.getPostComments(postId: widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments = data;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat komentar')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _sending) return;

    setState(() {
      _sending = true;
    });
    try {
      if (_replyTarget == null) {
        await ApiService.addPostComment(
            postId: widget.post.id, content: content);
      } else {
        await ApiService.addCommentReply(
          postId: widget.post.id,
          commentId: _replyTarget!.id,
          content: content,
        );
      }
      _controller.clear();
      setState(() {
        _replyTarget = null;
      });
      await _loadComments();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim komentar')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _sending = false;
      });
    }
  }

  List<Widget> _buildCommentNodes(List<CommunityComment> comments,
      {double indent = 0}) {
    final widgets = <Widget>[];
    for (final c in comments) {
      widgets.add(
        Container(
          margin: EdgeInsets.only(left: indent, bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _maskCommunityName(c.authorName),
                      style: _CommunityTypography.commentAuthor,
                    ),
                  ),
                  Text(
                    _formatCommunityTime(c.createdAt),
                    style: _CommunityTypography.commentTime,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                c.content,
                style: _CommunityTypography.commentBody,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _replyTarget = c;
                  });
                },
                child: const Text(
                  'Balas',
                  style: _CommunityTypography.commentReply,
                ),
              ),
            ],
          ),
        ),
      );
      if (c.replies.isNotEmpty) {
        widgets.addAll(_buildCommentNodes(c.replies, indent: indent + 16));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Komentar',
                      style: _CommunityTypography.commentTitle,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada komentar. Jadilah yang pertama.',
                            style: _CommunityTypography.emptyText,
                          ),
                        )
                      : ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          children: _buildCommentNodes(_comments),
                        ),
            ),
            if (_replyTarget != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                color: const Color(0xFFE9F7F0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Membalas ${_maskCommunityName(_replyTarget!.authorName)}',
                        style: const TextStyle(
                          color: Color(0xFF0B9A63),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _replyTarget = null),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.35,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        hintText: _replyTarget == null
                            ? 'Tulis komentar...'
                            : 'Tulis balasan...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9AA3B2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9DEE6)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _sending ? null : _sendComment,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _sending
                            ? const Color(0xFF91C9B3)
                            : const Color(0xFF0B9A63),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send,
                              color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
