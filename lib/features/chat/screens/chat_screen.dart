import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static const List<ChatMessage> _messages = [
    ChatMessage(
      sender: MessageSender.unknownStudent,
      text: 'Please... don\'t block me.',
      timestamp: '2:13 AM',
    ),
    ChatMessage(
      sender: MessageSender.unknownStudent,
      text: 'I don\'t have much time.',
      timestamp: '2:14 AM',
    ),
    ChatMessage(
      sender: MessageSender.unknownStudent,
      text: 'Something followed me.',
      timestamp: '2:14 AM',
    ),
    ChatMessage(
      sender: MessageSender.unknownStudent,
      text: 'It knows my name.',
      timestamp: '2:15 AM',
      isCorrupted: true,
    ),
    ChatMessage(
      sender: MessageSender.unknownStudent,
      text: 'I can hear it... right now.',
      timestamp: '2:16 AM',
      isCorrupted: true,
    ),
  ];

  static const List<String> _choices = [
    'Where are you?',
    'Who is this?',
    'What is following you?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/corridor.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha: 0.82)),
          Opacity(
            opacity: 0.12,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                const Color(0xFF7CFF41).withValues(alpha: 0.28),
                BlendMode.screen,
              ),
              child: Image.asset(
                'assets/images/corridor.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const _ChatScanlines(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Container(
                      decoration: _chatPanelDecoration(),
                      child: Column(
                        children: [
                          const SizedBox(height: 18),
                          const Text(
                            'ENCRYPTED CONNECTION ESTABLISHED',
                            style: TextStyle(
                              color: Color(0xFF7CFF41),
                              fontSize: 12,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '2:13 AM',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Opacity(
                                      opacity: 0.09,
                                      child: Image.asset(
                                        'assets/images/corridor.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                                  itemCount: _messages.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                                  itemBuilder: (context, index) {
                                    return _ChatBubble(message: _messages[index]);
                                  },
                                ),
                                const Positioned(
                                  right: 18,
                                  bottom: 18,
                                  child: _TypingIndicator(),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: const Color(0xFF7CFF41).withValues(alpha: 0.28),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                            child: Column(
                              children: [
                                const Text(
                                  'CHOOSE YOUR RESPONSE',
                                  style: TextStyle(
                                    color: Color(0xFF7CFF41),
                                    fontSize: 13,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ...List.generate(_choices.length, (index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: index == _choices.length - 1 ? 0 : 12),
                                    child: _ResponseOption(text: _choices[index]),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: _chatPanelDecoration(),
      child: Row(
        children: [
          _SquareTerminalButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'UNKNOWN CONTACT',
                  style: TextStyle(
                    color: Color(0xFF7CFF41),
                    fontSize: 18,
                    letterSpacing: 2.2,
                  ),
                ),
                SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'STATUS: ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: 'ONLINE \u25cf',
                        style: TextStyle(
                          color: Color(0xFF7CFF41),
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'SIGNAL: ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: '87%',
                      style: TextStyle(
                        color: Color(0xFF7CFF41),
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6),
              _ChatSignalBars(),
            ],
          ),
          const SizedBox(width: 16),
          const _SquareTerminalButton(icon: Icons.menu),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: _chatPanelDecoration(),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'LAST TRANSMISSION: 2:13 AM',
              style: TextStyle(
                color: Color(0xFF7CFF41),
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Text(
            'SIGNAL STRENGTH: 87%',
            style: TextStyle(
              color: Color(0xFF7CFF41),
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(width: 12),
          _ChatSignalBars(),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 18),
          child: Text(
            'UNKNOWN',
            style: TextStyle(
              color: Color(0xFF7CFF41),
              fontSize: 12,
              letterSpacing: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF7CFF41).withValues(alpha: 0.55),
                  ),
                  color: const Color(0xFF071106).withValues(alpha: 0.88),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7CFF41).withValues(alpha: message.isCorrupted ? 0.18 : 0.08),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isCorrupted ? const Color(0xFFA8FF87) : const Color(0xFFBFFF9A),
                    fontSize: 18,
                    letterSpacing: 1,
                    height: 1.25,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              message.timestamp,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResponseOption extends StatelessWidget {
  const _ResponseOption({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: _chatPanelDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.play_arrow_rounded,
            color: Color(0xFF7CFF41),
            size: 30,
          ),
          const SizedBox(width: 14),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFBFFF9A),
              fontSize: 18,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Text(
      'UNKNOWN IS TYPING... \u2022\u2022\u2022',
      style: TextStyle(
        color: const Color(0xFF7CFF41).withValues(alpha: 0.8),
        fontSize: 14,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _SquareTerminalButton extends StatelessWidget {
  const _SquareTerminalButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: _chatPanelDecoration(),
        child: Icon(
          icon,
          color: const Color(0xFF7CFF41),
          size: 26,
        ),
      ),
    );
  }
}

class _ChatSignalBars extends StatelessWidget {
  const _ChatSignalBars();

  @override
  Widget build(BuildContext context) {
    const heights = [10.0, 16.0, 22.0, 30.0];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights.map((height) {
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            width: 6,
            height: height,
            color: const Color(0xFF7CFF41),
          ),
        );
      }).toList(),
    );
  }
}

class _ChatScanlines extends StatelessWidget {
  const _ChatScanlines();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ChatScanlinePainter(),
        child: Container(),
      ),
    );
  }
}

class _ChatScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF7CFF41).withValues(alpha: 0.025)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset.zero.translate(0, y), Offset(size.width, y), linePaint);
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.78),
        ],
        stops: const [0.5, 1],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

BoxDecoration _chatPanelDecoration() {
  return BoxDecoration(
    border: Border.all(
      color: const Color(0xFF7CFF41).withValues(alpha: 0.34),
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF7CFF41).withValues(alpha: 0.07),
        blurRadius: 16,
      ),
    ],
    color: const Color(0xFF020502).withValues(alpha: 0.82),
  );
}
