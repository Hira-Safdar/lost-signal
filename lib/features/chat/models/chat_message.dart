enum MessageSender { unknownStudent, player, system }

class ChatMessage {
  const ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isCorrupted = false,
  });

  final MessageSender sender;
  final String text;
  final String timestamp;
  final bool isCorrupted;
}
