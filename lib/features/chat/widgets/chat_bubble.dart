import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isPlayer = message.sender == MessageSender.player;
    final isSystem = message.sender == MessageSender.system;

    if (isSystem) {
      return Center(
        child: Text(
          message.text,
          style: const TextStyle(color: AppTheme.mutedText, fontSize: 12),
        ),
      );
    }

    return Align(
      alignment: isPlayer ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isPlayer ? AppTheme.outgoingBubble : AppTheme.incomingBubble,
            borderRadius: BorderRadius.circular(8),
            border: message.isCorrupted
                ? Border.all(color: AppTheme.warningRed.withValues(alpha: 0.55))
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: message.isCorrupted
                        ? const Color(0xFFFFB4B4)
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.timestamp,
                  style: const TextStyle(
                    color: AppTheme.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
