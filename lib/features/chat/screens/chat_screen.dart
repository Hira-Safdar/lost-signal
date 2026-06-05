import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/choice_button.dart';
import '../widgets/signal_meter.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static const List<ChatMessage> _messages = [
    ChatMessage(
      sender: MessageSender.system,
      text: 'Incoming connection detected.',
      timestamp: '02:13 AM',
    ),
    ChatMessage(
      sender: MessageSender.unknownStudent,
      text: 'Please answer. I am inside the old media block.',
      timestamp: '02:14 AM',
    ),
    ChatMessage(
      sender: MessageSender.unknownStudent,
      text: 'The doors are locked and my phone signal keeps dropping.',
      timestamp: '02:14 AM',
    ),
    ChatMessage(
      sender: MessageSender.unknownStudent,
      text: 'I think someone is walking in the hallway.',
      timestamp: '02:15 AM',
      isCorrupted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unknown Student'),
            SizedBox(height: 2),
            Text(
              'Signal unstable',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
            ),
          ],
        ),
        leading: const Icon(Icons.lock_outline),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: SignalMeter(value: 0.42),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                itemBuilder: (context, index) {
                  return ChatBubble(message: _messages[index]);
                },
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemCount: _messages.length,
              ),
            ),
            const Divider(height: 1, color: Color(0xFF202733)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: const [
                  ChoiceButton(text: 'Ask where exactly they are'),
                  SizedBox(height: 8),
                  ChoiceButton(text: 'Tell them to stay silent'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
