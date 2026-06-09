import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lost_signal/shared/settings/app_settings.dart';

import '../../story/models/player_profile.dart';
import '../../story/screens/campus_map_screen.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.gender});

  final PlayerGender gender;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const List<ChatMessage> _seedMessages = [
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
      text: 'I left the dormitory after someone called me to Room 207. Something followed me from the stairwell.',
      timestamp: '2:14 AM',
    ),
    ChatMessage(
      sender: MessageSender.unknownStudent,
      text: 'It knows my name. It started after I checked the missing report board.',
      timestamp: '2:15 AM',
      isCorrupted: true,
    ),
    ChatMessage(
      sender: MessageSender.unknownStudent,
      text: 'I can hear it... right now. If I lose signal, check engineering first.',
      timestamp: '2:16 AM',
      isCorrupted: true,
    ),
  ];

  static const Map<String, _StoryNodeBase> _storyGraph = {
    'entry': _StoryNode(
      id: 'entry',
      prompt: 'CHOOSE YOUR RESPONSE',
      choices: [
        _StoryChoice(
          text: 'Where are you?',
          signalDelta: -6,
          nextNodeId: 'location',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Engineering Block. Room 207 is dark, but the notice board outside still has my face on it.',
            timestamp: '2:16 AM',
          ),
        ),
        _StoryChoice(
          text: 'Who is this?',
          signalDelta: -14,
          nextNodeId: 'identity',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Nathan. Nathan Kim. If that name means nothing, look at the report in admin.',
            timestamp: '2:17 AM',
            isCorrupted: true,
          ),
        ),
        _StoryChoice(
          text: 'What is following you?',
          signalDelta: -9,
          nextNodeId: 'threat',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'I never saw it clearly. It sounds like shoes dragging and keys hitting metal behind me.',
            timestamp: '2:17 AM',
          ),
        ),
      ],
    ),
    'location': _StoryNode(
      id: 'location',
      prompt: 'SIGNAL ROUTED: LOCATION TRACE',
      choices: [
        _StoryChoice(
          text: 'Stay where you are.',
          signalDelta: -7,
          nextNodeId: 'ending_stay',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'I tried. It gets closer whenever I stop near the engineering desk. My ID is still there.',
            timestamp: '2:18 AM',
          ),
        ),
        _StoryChoice(
          text: 'Hide somewhere.',
          signalDelta: -18,
          nextNodeId: 'ending_hide',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'There is a locked lab here. Door says 207. I can hear the same static from inside that came through my phone.',
            timestamp: '2:18 AM',
            isCorrupted: true,
          ),
        ),
        _StoryChoice(
          text: 'I am coming.',
          signalDelta: -12,
          nextNodeId: 'ending_come',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Then bring proof. My student card, the report, and anything that opens the basement door.',
            timestamp: '2:18 AM',
          ),
        ),
      ],
    ),
    'identity': _StoryNode(
      id: 'identity',
      prompt: 'MEMORY CONFLICT DETECTED',
      choices: [
        _StoryChoice(
          text: 'Why do I know you?',
          signalDelta: -8,
          nextNodeId: 'ending_memory',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Because you saw my report this morning and kept walking. You were the only one who stopped reading it.',
            timestamp: '2:18 AM',
            isCorrupted: true,
          ),
        ),
        _StoryChoice(
          text: 'You have the wrong number.',
          signalDelta: -20,
          nextNodeId: 'ending_wrong',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'No. This phone unlocked when it saw your number in my broken contacts draft.',
            timestamp: '2:18 AM',
            isCorrupted: true,
          ),
        ),
        _StoryChoice(
          text: 'Tell me your name.',
          signalDelta: -10,
          nextNodeId: 'ending_name',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Nathan Kim. If the text glitches again, check my ID. It has to still be upstairs.',
            timestamp: '2:19 AM',
          ),
        ),
      ],
    ),
    'threat': _StoryNode(
      id: 'threat',
      prompt: 'THREAT RESPONSE WINDOW OPEN',
      choices: [
        _StoryChoice(
          text: 'Keep moving.',
          signalDelta: -6,
          nextNodeId: 'ending_move',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'It hates movement. I think it wants me cornered until someone opens the basement route for it.',
            timestamp: '2:18 AM',
          ),
        ),
        _StoryChoice(
          text: 'Turn around and look.',
          signalDelta: -22,
          nextNodeId: 'ending_look',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'I did once. It was standing where my missing poster should have been.',
            timestamp: '2:19 AM',
            isCorrupted: true,
          ),
        ),
        _StoryChoice(
          text: 'Lock the nearest door.',
          signalDelta: -11,
          nextNodeId: 'ending_lock',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'The doors lock from the outside only. Someone used a campus security card and planned this.',
            timestamp: '2:18 AM',
          ),
        ),
      ],
    ),
    'ending_stay': _EndingNode(
      id: 'ending_stay',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'Signal weakening. Footsteps detected outside Room 207. Engineering desk ping preserved.',
        timestamp: '2:19 AM',
        isCorrupted: true,
      ),
    ),
    'ending_hide': _EndingNode(
      id: 'ending_hide',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'Connection unstable. Door 207 opened from inside. Archive route to admin recommended.',
        timestamp: '2:19 AM',
        isCorrupted: true,
      ),
    ),
    'ending_come': _EndingNode(
      id: 'ending_come',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'Transmission held. Route to campus saved. Recover Nathan Kim\'s trail before the basement opens.',
        timestamp: '2:19 AM',
      ),
    ),
    'ending_memory': _EndingNode(
      id: 'ending_memory',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'Archive fragment restored. Missing-student file linked to Room 207 and a basement maintenance route.',
        timestamp: '2:19 AM',
      ),
    ),
    'ending_wrong': _EndingNode(
      id: 'ending_wrong',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'Identity mismatch denied. Broken phone contact list still points to you.',
        timestamp: '2:19 AM',
        isCorrupted: true,
      ),
    ),
    'ending_name': _EndingNode(
      id: 'ending_name',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'Name confirmed: Nathan Kim. Student ID verification pending on campus.',
        timestamp: '2:20 AM',
      ),
    ),
    'ending_move': _EndingNode(
      id: 'ending_move',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'Motion preserved the link. Contact still mobile near the route below Engineering Block.',
        timestamp: '2:19 AM',
      ),
    ),
    'ending_look': _EndingNode(
      id: 'ending_look',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'Visual contact established. Missing-poster match detected. Feed terminated.',
        timestamp: '2:19 AM',
        isCorrupted: true,
      ),
    ),
    'ending_lock': _EndingNode(
      id: 'ending_lock',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'External lock protocol failed. Security-card access points remain active across campus.',
        timestamp: '2:19 AM',
      ),
    ),
  };

  final List<ChatMessage> _messages = List<ChatMessage>.from(_seedMessages);
  final ScrollController _scrollController = ScrollController();

  String _currentNodeId = 'entry';
  int _signalStrength = 87;
  int _trustScore = 58;
  bool _isTyping = false;
  bool _isLocked = false;
  Timer? _replyTimer;

  @override
  void dispose() {
    _replyTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleChoiceTap(int index) {
    final node = _currentNode;
    if (node is _EndingNode) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CampusMapScreen(
            gender: widget.gender,
            signalStrength: _signalStrength,
            trustScore: _trustScore,
          ),
        ),
      );
      return;
    }

    if (_isLocked) {
      return;
    }
    final selectedChoice = (node as _StoryNode).choices[index];

    setState(() {
      _isLocked = true;
      _messages.add(
        ChatMessage(
          sender: MessageSender.player,
          text: selectedChoice.text,
          timestamp: _playerTimestamp,
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _signalStrength = (_signalStrength + selectedChoice.signalDelta)
            .clamp(24, 99)
            .toInt();
        _trustScore = (_trustScore + (selectedChoice.signalDelta > -10 ? 4 : -6))
            .clamp(20, 90)
            .toInt();
        _messages.add(selectedChoice.response);
        _isTyping = false;
        _currentNodeId = selectedChoice.nextNodeId;
        final nextNode = _currentNode;
        if (nextNode is _EndingNode) {
          _messages.add(nextNode.finalMessage);
          _isLocked = true;
        } else {
          _isLocked = false;
        }
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  String get _playerTimestamp {
    final minute = 16 + ((_messages.length - _seedMessages.length) ~/ 2);
    return '2:${minute.toString().padLeft(2, '0')} AM';
  }

  _StoryNodeBase get _currentNode => _storyGraph[_currentNodeId]!;

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/corridor.png',
                fit: BoxFit.cover,
              ),
              Container(color: Colors.black.withValues(alpha: 0.86)),
              Opacity(
                opacity: 0.14,
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
              if (settings.scanlinesEnabled) const _ChatScanlines(),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 12 : 18,
                    isCompact ? 12 : 18,
                    isCompact ? 12 : 18,
                    isCompact ? 10 : 18,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(context, isCompact),
                      SizedBox(height: isCompact ? 10 : 14),
                      Expanded(
                        child: Container(
                          decoration: _chatPanelDecoration(radius: isCompact ? 14 : 0),
                          child: Column(
                            children: [
                              SizedBox(height: isCompact ? 12 : 18),
                              Text(
                                'ENCRYPTED CONNECTION ESTABLISHED',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF7CFF41),
                                  fontSize: isCompact ? 10 : 12,
                                  letterSpacing: isCompact ? 1.0 : 1.6,
                                ),
                              ),
                              SizedBox(height: isCompact ? 6 : 8),
                              if (settings.subtitlesEnabled)
                                Text(
                                  '${widget.gender.subject} received the first message at 2:13 AM',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: isCompact ? 10 : 12,
                                    letterSpacing: isCompact ? 0.6 : 1.0,
                                  ),
                                ),
                              SizedBox(height: isCompact ? 10 : 14),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Opacity(
                                          opacity: isCompact ? 0.05 : 0.09,
                                          child: Image.asset(
                                            'assets/images/corridor.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ListView.separated(
                                      controller: _scrollController,
                                      padding: EdgeInsets.fromLTRB(
                                        isCompact ? 12 : 18,
                                        0,
                                        isCompact ? 12 : 18,
                                        isCompact ? 12 : 16,
                                      ),
                                      itemCount: _messages.length,
                                      separatorBuilder: (_, _) => SizedBox(height: isCompact ? 10 : 14),
                                      itemBuilder: (context, index) {
                                        return _ChatBubble(
                                          message: _messages[index],
                                          compact: isCompact,
                                        );
                                      },
                                    ),
                                    if (_isTyping)
                                      Positioned(
                                        right: isCompact ? 12 : 18,
                                        bottom: isCompact ? 10 : 18,
                                        child: _TypingIndicator(compact: isCompact),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 1,
                                color: const Color(0xFF7CFF41).withValues(alpha: 0.28),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isCompact ? 12 : 18,
                                  isCompact ? 12 : 16,
                                  isCompact ? 12 : 18,
                                  isCompact ? 12 : 18,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _currentNode is _EndingNode
                                          ? 'CONNECTION ENDED'
                                          : (_currentNode as _StoryNode).prompt,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: const Color(0xFF7CFF41),
                                        fontSize: isCompact ? 11 : 13,
                                        letterSpacing: isCompact ? 1.3 : 2,
                                      ),
                                    ),
                                    SizedBox(height: isCompact ? 10 : 14),
                                    ...List.generate(_visibleChoices.length, (index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: index == _visibleChoices.length - 1
                                              ? 0
                                              : (isCompact ? 8 : 12),
                                        ),
                                        child: _ResponseOption(
                                          text: _visibleChoices[index],
                                          compact: isCompact,
                                          disabled: _isLocked && _currentNode is! _EndingNode,
                                          onTap: () => _handleChoiceTap(index),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 10 : 14),
                      _buildFooter(isCompact),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 18,
        vertical: isCompact ? 10 : 16,
      ),
      decoration: _chatPanelDecoration(radius: isCompact ? 14 : 0),
      child: Row(
        children: [
          _SquareTerminalButton(
            icon: Icons.arrow_back_ios_new,
            compact: isCompact,
            onTap: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: isCompact ? 10 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UNKNOWN CONTACT',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF7CFF41),
                    fontSize: isCompact ? 14 : 18,
                    letterSpacing: isCompact ? 1.4 : 2.2,
                  ),
                ),
                SizedBox(height: isCompact ? 2 : 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      'STATUS:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isCompact ? 10 : 12,
                        letterSpacing: isCompact ? 1.0 : 1.5,
                      ),
                    ),
                    Text(
                      _isTyping
                          ? 'TYPING \u25cf'
                          : (_currentNode is _EndingNode
                              ? 'OFFLINE \u25cf'
                              : 'ONLINE \u25cf'),
                      style: TextStyle(
                        color: const Color(0xFF7CFF41),
                        fontSize: isCompact ? 10 : 12,
                        letterSpacing: isCompact ? 1.0 : 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: isCompact ? 8 : 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_signalStrength%',
                style: TextStyle(
                  color: const Color(0xFF7CFF41),
                  fontSize: isCompact ? 11 : 12,
                  letterSpacing: isCompact ? 1.0 : 1.5,
                ),
              ),
              SizedBox(height: isCompact ? 4 : 6),
              _ChatSignalBars(
                compact: isCompact,
                weak: _signalStrength <= 45,
              ),
            ],
          ),
          SizedBox(width: isCompact ? 8 : 16),
          _SquareTerminalButton(
            icon: Icons.menu_rounded,
            compact: isCompact,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 18,
        vertical: isCompact ? 10 : 14,
      ),
      decoration: _chatPanelDecoration(radius: isCompact ? 14 : 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAST TRANSMISSION',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isCompact ? 9 : 12,
                    letterSpacing: isCompact ? 0.9 : 1.5,
                  ),
                ),
                SizedBox(height: isCompact ? 4 : 6),
                Text(
                  _messages.last.timestamp,
                  style: TextStyle(
                    color: const Color(0xFF7CFF41),
                    fontSize: isCompact ? 13 : 16,
                    letterSpacing: isCompact ? 1.2 : 1.8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isCompact ? 12 : 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SIGNAL $_signalStrength%',
                style: TextStyle(
                  color: const Color(0xFF7CFF41),
                  fontSize: isCompact ? 10 : 12,
                  letterSpacing: isCompact ? 1.0 : 1.5,
                ),
              ),
              SizedBox(height: isCompact ? 4 : 6),
              _ChatSignalBars(
                compact: isCompact,
                weak: _signalStrength <= 45,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<String> get _visibleChoices {
    final node = _currentNode;
    if (node is _EndingNode) {
      return const [
        'ENTER CAMPUS',
        'OPEN CASE FILE',
        'CHECK LAST PING',
      ];
    }
    return (node as _StoryNode)
        .choices
        .map((choice) => choice.text)
        .toList(growable: false);
  }
}

abstract class _StoryNodeBase {
  const _StoryNodeBase({required this.id});

  final String id;
}

class _StoryNode extends _StoryNodeBase {
  const _StoryNode({
    required super.id,
    required this.prompt,
    required this.choices,
  });

  final String prompt;
  final List<_StoryChoice> choices;
}

class _EndingNode extends _StoryNodeBase {
  const _EndingNode({
    required super.id,
    required this.finalMessage,
  });

  final ChatMessage finalMessage;
}

class _StoryChoice {
  const _StoryChoice({
    required this.text,
    required this.signalDelta,
    required this.nextNodeId,
    required this.response,
  });

  final String text;
  final int signalDelta;
  final String nextNodeId;
  final ChatMessage response;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.compact,
  });

  final ChatMessage message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isPlayer = message.sender == MessageSender.player;

    return Column(
      crossAxisAlignment:
          isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: isPlayer ? 0 : (compact ? 10 : 18),
            right: isPlayer ? (compact ? 10 : 18) : 0,
          ),
          child: Text(
            isPlayer ? 'YOU' : 'UNKNOWN',
            style: TextStyle(
              color: isPlayer
                  ? const Color(0xFFB8FFD8)
                  : const Color(0xFF7CFF41),
              fontSize: compact ? 10 : 12,
              letterSpacing: compact ? 1.0 : 1.6,
            ),
          ),
        ),
        SizedBox(height: compact ? 4 : 6),
        Row(
          mainAxisAlignment:
              isPlayer ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isPlayer) ...[
              Padding(
                padding: EdgeInsets.only(bottom: compact ? 4 : 6),
                child: Text(
                  message.timestamp,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: compact ? 10 : 12,
                    letterSpacing: compact ? 0.8 : 1.5,
                  ),
                ),
              ),
              SizedBox(width: compact ? 8 : 16),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  compact ? 12 : 18,
                  compact ? 10 : 14,
                  compact ? 12 : 18,
                  compact ? 10 : 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(compact ? 12 : 0),
                  border: Border.all(
                    color: (isPlayer
                            ? const Color(0xFFB8FFD8)
                            : const Color(0xFF7CFF41))
                        .withValues(alpha: 0.55),
                  ),
                  color: (isPlayer
                          ? const Color(0xFF08130A)
                          : const Color(0xFF071106))
                      .withValues(alpha: 0.88),
                  boxShadow: [
                    BoxShadow(
                      color: (isPlayer
                              ? const Color(0xFFB8FFD8)
                              : const Color(0xFF7CFF41))
                          .withValues(
                        alpha: message.isCorrupted ? 0.18 : 0.08,
                      ),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: isPlayer
                        ? const Color(0xFFD9FFE6)
                        : (message.isCorrupted
                            ? const Color(0xFFA8FF87)
                            : const Color(0xFFBFFF9A)),
                    fontSize: compact ? 14 : 18,
                    letterSpacing: compact ? 0.4 : 1,
                    height: 1.25,
                  ),
                ),
              ),
            ),
            if (!isPlayer) ...[
              SizedBox(width: compact ? 8 : 16),
              Padding(
                padding: EdgeInsets.only(bottom: compact ? 4 : 6),
                child: Text(
                  message.timestamp,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: compact ? 10 : 12,
                    letterSpacing: compact ? 0.8 : 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ResponseOption extends StatelessWidget {
  const _ResponseOption({
    required this.text,
    required this.compact,
    required this.disabled,
    required this.onTap,
  });

  final String text;
  final bool compact;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.55 : 1,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 18,
            vertical: compact ? 12 : 18,
          ),
          decoration: _chatPanelDecoration(radius: compact ? 12 : 0),
          child: Row(
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: const Color(0xFF7CFF41),
                size: compact ? 22 : 30,
              ),
              SizedBox(width: compact ? 10 : 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: const Color(0xFFBFFF9A),
                    fontSize: compact ? 15 : 18,
                    letterSpacing: compact ? 0.8 : 1.4,
                    height: 1.15,
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

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      'UNKNOWN IS TYPING... \u2022\u2022\u2022',
      textAlign: TextAlign.right,
      style: TextStyle(
        color: const Color(0xFF7CFF41).withValues(alpha: 0.8),
        fontSize: compact ? 10 : 14,
        letterSpacing: compact ? 0.8 : 1.4,
      ),
    );
  }
}

class _SquareTerminalButton extends StatelessWidget {
  const _SquareTerminalButton({
    required this.icon,
    required this.compact,
    this.onTap,
  });

  final IconData icon;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 52.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: _chatPanelDecoration(radius: compact ? 12 : 0),
        child: Icon(
          icon,
          color: const Color(0xFF7CFF41),
          size: compact ? 20 : 26,
        ),
      ),
    );
  }
}

class _ChatSignalBars extends StatelessWidget {
  const _ChatSignalBars({
    required this.compact,
    this.weak = false,
  });

  final bool compact;
  final bool weak;

  @override
  Widget build(BuildContext context) {
    final heights = compact
        ? const [6.0, 10.0, 14.0, 18.0]
        : const [10.0, 16.0, 22.0, 30.0];
    final activeCount = weak ? 2 : 4;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(heights.length, (index) {
        return Padding(
          padding: EdgeInsets.only(left: compact ? 3 : 4),
          child: Container(
            width: compact ? 4 : 6,
            height: heights[index],
            color: index < activeCount
                ? const Color(0xFF7CFF41)
                : const Color(0xFF7CFF41).withValues(alpha: 0.18),
          ),
        );
      }),
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
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
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

BoxDecoration _chatPanelDecoration({double radius = 0}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
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
