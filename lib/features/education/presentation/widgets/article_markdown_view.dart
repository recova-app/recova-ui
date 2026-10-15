import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Reusable markdown viewer for article content and education summaries.
class ArticleMarkdownView extends StatelessWidget {
  final String data;
  final bool selectable;
  final void Function(String text, String? href, String title)? onTapLink;

  const ArticleMarkdownView({
    super.key,
    required this.data,
    this.selectable = false,
    this.onTapLink,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: selectable,
      onTapLink: onTapLink,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
    );
  }
}
