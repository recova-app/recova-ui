import 'package:flutter/material.dart';

/// Modular input bar for AI coach conversations with loading state and send trigger.
class CoachChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const CoachChatInputBar({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colorScheme.surface),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !isSending,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'Reply ...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: isSending ? null : onSend,
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSending ? colorScheme.outline : colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child:
                      isSending
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                          : Icon(
                            Icons.send,
                            color: colorScheme.onPrimary,
                            size: 16,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
