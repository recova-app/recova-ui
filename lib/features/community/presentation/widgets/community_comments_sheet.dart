import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recova/core/theme/recovery_theme_extension.dart';
import 'package:recova/core/ui/app_toast.dart';
import 'package:recova/features/community/domain/repositories/community_repository.dart';
import 'package:recova/features/community/presentation/widgets/community_post_card.dart';
import 'package:recova/models/community_comment_model.dart';
import 'package:recova/models/post_model.dart';

class CommunityCommentsSheet extends StatefulWidget {
  final Post post;
  final CommunityRepository? repository;

  const CommunityCommentsSheet({
    super.key,
    required this.post,
    this.repository,
  });

  @override
  State<CommunityCommentsSheet> createState() => _CommunityCommentsSheetState();
}

class _CommunityCommentsSheetState extends State<CommunityCommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<CommunityComment> _comments = const [];
  bool _loading = true;
  bool _sending = false;
  CommunityComment? _replyTarget;

  CommunityRepository get _repo =>
      widget.repository ?? context.read<CommunityRepository>();

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
      final data = await _repo.getPostComments(widget.post.id);
      if (!mounted) return;
      setState(() {
        _comments = data;
      });
    } catch (_) {
      if (!mounted) return;
      AppToast.showError(context, 'Gagal memuat komentar');
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
        await _repo.addPostComment(postId: widget.post.id, content: content);
      } else {
        await _repo.addCommentReply(
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
      AppToast.showError(context, 'Gagal mengirim komentar');
    } finally {
      if (!mounted) return;
      setState(() {
        _sending = false;
      });
    }
  }

  List<Widget> _buildCommentNodes(
    BuildContext context,
    List<CommunityComment> comments, {
    double indent = 0,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final widgets = <Widget>[];

    for (final c in comments) {
      widgets.add(
        Container(
          margin: EdgeInsets.only(left: indent, bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      maskCommunityName(c.authorName),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    formatRelativeCommunityTime(c.createdAt),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                c.content,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  height: 1.42,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _replyTarget = c;
                  });
                },
                child: Text(
                  'Balas',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      if (c.replies.isNotEmpty) {
        widgets.addAll(
          _buildCommentNodes(context, c.replies, indent: indent + 16),
        );
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recoveryTheme = context.recoveryTheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Komentar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: colorScheme.onSurface),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _comments.isEmpty
                      ? Center(
                        child: Text(
                          'Belum ada komentar. Jadilah yang pertama.',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      )
                      : ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        children: _buildCommentNodes(context, _comments),
                      ),
            ),
            if (_replyTarget != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                color: recoveryTheme.accentSurface,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Membalas ${_replyTarget!.authorName}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        setState(() {
                          _replyTarget = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            _replyTarget == null
                                ? 'Tulis komentar...'
                                : 'Tulis balasan untuk ${_replyTarget!.authorName}...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sending ? null : _sendComment,
                    icon:
                        _sending
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            )
                            : Icon(
                              Icons.send_rounded,
                              color: colorScheme.primary,
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
