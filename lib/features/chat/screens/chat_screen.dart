import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lost_signal/shared/game/game_controller.dart';
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
  static const Map<String, String> _locationBackgrounds = {
    'dormitory': 'assets/images/dormitory.png',
    'engineering': 'assets/images/engineering_block.png',
    'admin': 'assets/images/admin.png',
    'library': 'assets/images/library.png',
    'basement': 'assets/images/basement.png',
  };

  static const Map<String, String> _locationLabels = {
    'dormitory': 'DORM STAIRWELL',
    'engineering': 'ENGINEERING BLOCK',
    'admin': 'ADMIN CORRIDOR',
    'library': 'LIBRARY STAIRS',
    'basement': 'BASEMENT ACCESS',
  };

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
  ];

  static const Map<String, _StoryNodeBase> _storyGraph = {
    'entry': _StoryNode(
      id: 'entry',
      prompt: 'CHOOSE YOUR RESPONSE',
      choices: [
        _StoryChoice(
          text: 'Where are you right now?',
          signalDelta: -5,
          nextNodeId: 'dorm_location',
          locationId: 'dormitory',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Dormitory west stairwell. I left my room because someone texted me to come downstairs.',
            timestamp: '2:15 AM',
          ),
        ),
        _StoryChoice(
          text: 'Who is this?',
          signalDelta: -7,
          nextNodeId: 'dorm_identity',
          locationId: 'dormitory',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Nathan. Nathan Kim. Third year. Please tell me you can see these messages.',
            timestamp: '2:15 AM',
            isCorrupted: true,
          ),
        ),
        _StoryChoice(
          text: 'What happened?',
          signalDelta: -6,
          nextNodeId: 'dorm_threat',
          locationId: 'dormitory',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Something started following me after I checked the missing report board. I hear it every time the hall goes quiet.',
            timestamp: '2:15 AM',
          ),
        ),
      ],
    ),
    'dorm_location': _StoryNode(
      id: 'dorm_location',
      prompt: 'LAST PING: DORM STAIRWELL',
      choices: [
        _StoryChoice(
          text: 'Go somewhere brighter.',
          signalDelta: -7,
          nextNodeId: 'engineering_trace',
          locationId: 'engineering',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Moving to Engineering Block. The main corridor lights are still on there.',
            timestamp: '2:16 AM',
          ),
        ),
        _StoryChoice(
          text: 'Hide and stay quiet.',
          signalDelta: -14,
          nextNodeId: 'dorm_hide',
          locationId: 'dormitory',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Silence makes it stop outside the door. That feels worse.',
            timestamp: '2:16 AM',
            isCorrupted: true,
          ),
        ),
        _StoryChoice(
          text: 'Call campus security.',
          signalDelta: -12,
          nextNodeId: 'admin_trace',
          locationId: 'admin',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'I tried. The line cut out. I am heading toward admin instead.',
            timestamp: '2:16 AM',
          ),
        ),
      ],
    ),
    'dorm_identity': _StoryNode(
      id: 'dorm_identity',
      prompt: 'IDENTITY CHECK',
      choices: [
        _StoryChoice(
          text: 'How do I know you are real?',
          signalDelta: -7,
          nextNodeId: 'engineering_trace',
          locationId: 'engineering',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'My student ID is on an engineering desk. I dropped it when I started running.',
            timestamp: '2:16 AM',
          ),
        ),
        _StoryChoice(
          text: 'Why message me?',
          signalDelta: -8,
          nextNodeId: 'admin_trace',
          locationId: 'admin',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Because you stopped at the missing report this morning. I thought you might come back.',
            timestamp: '2:16 AM',
          ),
        ),
        _StoryChoice(
          text: 'Tell me your route.',
          signalDelta: -5,
          nextNodeId: 'engineering_trace',
          locationId: 'engineering',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Dorm. Engineering. Admin. Library. I think it wants me below campus.',
            timestamp: '2:16 AM',
          ),
        ),
      ],
    ),
    'dorm_threat': _StoryNode(
      id: 'dorm_threat',
      prompt: 'THREAT RESPONSE WINDOW OPEN',
      choices: [
        _StoryChoice(
          text: 'Keep walking and update me.',
          signalDelta: -5,
          nextNodeId: 'engineering_trace',
          locationId: 'engineering',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Okay. I am in Engineering now. There is a missing poster here with my face on it.',
            timestamp: '2:16 AM',
          ),
        ),
        _StoryChoice(
          text: 'Look behind you once.',
          signalDelta: -18,
          nextNodeId: 'dorm_hide',
          locationId: 'dormitory',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'I looked. Nothing there. But the end door was open.',
            timestamp: '2:16 AM',
            isCorrupted: true,
          ),
        ),
        _StoryChoice(
          text: 'Find the nearest locked room.',
          signalDelta: -9,
          nextNodeId: 'engineering_trace',
          locationId: 'engineering',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Engineering has locked rooms. Some only lock from outside. That is not normal.',
            timestamp: '2:16 AM',
          ),
        ),
      ],
    ),
    'dorm_hide': _StoryNode(
      id: 'dorm_hide',
      prompt: 'SIGNAL DETERIORATING',
      choices: [
        _StoryChoice(
          text: 'Run now.',
          signalDelta: -8,
          nextNodeId: 'engineering_trace',
          locationId: 'engineering',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Running. I made it into Engineering. My hands are shaking.',
            timestamp: '2:17 AM',
          ),
        ),
        _StoryChoice(
          text: 'What do you hear?',
          signalDelta: -10,
          nextNodeId: 'engineering_trace',
          locationId: 'engineering',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Dragging shoes. Metal keys. It gets louder when the hall goes dark.',
            timestamp: '2:17 AM',
          ),
        ),
      ],
    ),
    'engineering_trace': _StoryNode(
      id: 'engineering_trace',
      prompt: 'LAST PING: ENGINEERING BLOCK',
      choices: [
        _StoryChoice(
          text: 'Check the desk area.',
          signalDelta: -6,
          nextNodeId: 'admin_trace',
          locationId: 'admin',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Found my ID near a desk. I am moving toward admin now.',
            timestamp: '2:17 AM',
          ),
        ),
        _StoryChoice(
          text: 'What else do you see there?',
          signalDelta: -7,
          nextNodeId: 'admin_trace',
          locationId: 'admin',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'A missing poster. My face. It should not still be here.',
            timestamp: '2:17 AM',
          ),
        ),
        _StoryChoice(
          text: 'Skip ahead. Go to admin.',
          signalDelta: -8,
          nextNodeId: 'admin_trace',
          locationId: 'admin',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'On the way. Admin corridor feels empty in a bad way.',
            timestamp: '2:17 AM',
          ),
        ),
      ],
    ),
    'admin_trace': _StoryNode(
      id: 'admin_trace',
      prompt: 'LAST PING: ADMIN CORRIDOR',
      choices: [
        _StoryChoice(
          text: 'Is the report still there?',
          signalDelta: -6,
          nextNodeId: 'library_trace',
          locationId: 'library',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Yes. Someone stamped it and circled my name. I am heading to the library stairs.',
            timestamp: '2:18 AM',
          ),
        ),
        _StoryChoice(
          text: 'Did anyone see you?',
          signalDelta: -8,
          nextNodeId: 'library_trace',
          locationId: 'library',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'No one. Just my report and an open archive side door down the hall.',
            timestamp: '2:18 AM',
          ),
        ),
        _StoryChoice(
          text: 'Keep moving. Do not stop there.',
          signalDelta: -5,
          nextNodeId: 'library_trace',
          locationId: 'library',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Moving. Library signal is weaker already.',
            timestamp: '2:18 AM',
          ),
        ),
      ],
    ),
    'library_trace': _StoryNode(
      id: 'library_trace',
      prompt: 'LAST PING: LIBRARY STAIRS',
      choices: [
        _StoryChoice(
          text: 'Did you find your phone?',
          signalDelta: -6,
          nextNodeId: 'basement_trace',
          locationId: 'basement',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Yes. Screen cracked. There is a draft mentioning a basement service door.',
            timestamp: '2:19 AM',
          ),
        ),
        _StoryChoice(
          text: 'Send me anything else you found.',
          signalDelta: -7,
          nextNodeId: 'basement_trace',
          locationId: 'basement',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'A blurred photo too. Admin corridor. Same night. I am moving again.',
            timestamp: '2:19 AM',
          ),
        ),
        _StoryChoice(
          text: 'Where does this route end?',
          signalDelta: -8,
          nextNodeId: 'basement_trace',
          locationId: 'basement',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Below campus. There is a maintenance way down behind the archive side.',
            timestamp: '2:19 AM',
          ),
        ),
      ],
    ),
    'basement_trace': _StoryNode(
      id: 'basement_trace',
      prompt: 'FINAL ROUTE CONFIRMED',
      choices: [
        _StoryChoice(
          text: 'I am coming to campus.',
          signalDelta: -8,
          nextNodeId: 'ending_come',
          locationId: 'basement',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'Then follow the trail. Engineering. Admin. Library. Basement. Do not skip anything.',
            timestamp: '2:20 AM',
          ),
        ),
        _StoryChoice(
          text: 'Stay online. Keep talking.',
          signalDelta: -6,
          nextNodeId: 'ending_move',
          locationId: 'basement',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'I am trying. The door below campus is open now.',
            timestamp: '2:20 AM',
          ),
        ),
        _StoryChoice(
          text: 'Do not go down there alone.',
          signalDelta: -10,
          nextNodeId: 'ending_lock',
          locationId: 'basement',
          response: ChatMessage(
            sender: MessageSender.unknownStudent,
            text: 'I may not have a choice. Something is behind me again.',
            timestamp: '2:20 AM',
            isCorrupted: true,
          ),
        ),
      ],
    ),
    'ending_come': _EndingNode(
      id: 'ending_come',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'Transmission held. Route to campus saved. Recover Nathan Kim\'s trail before the basement opens.',
        timestamp: '2:20 AM',
      ),
    ),
    'ending_move': _EndingNode(
      id: 'ending_move',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'Motion preserved the link. Contact still mobile near the basement access route.',
        timestamp: '2:20 AM',
      ),
    ),
    'ending_lock': _EndingNode(
      id: 'ending_lock',
      finalMessage: ChatMessage(
        sender: MessageSender.system,
        text: 'External lock protocol failed. Security-card access points remain active across campus.',
        timestamp: '2:20 AM',
      ),
    ),
  };

  final List<ChatMessage> _messages = <ChatMessage>[];
  final ScrollController _scrollController = ScrollController();

  String _currentNodeId = 'entry';
  String _currentLocationId = 'dormitory';
  int _signalStrength = 87;
  int _trustScore = 58;
  bool _isTyping = false;
  bool _isLocked = true;
  Timer? _replyTimer;
  Timer? _introTimer;
  int _introIndex = 0;
  GameController? _game;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final game = GameScope.of(context);
    if (!identical(_game, game)) {
      _game = game;
      _hydrateFromSave(game);
    }
  }

  @override
  void dispose() {
    _replyTimer?.cancel();
    _introTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startIntroSequence() {
    _queueNextIntroMessage(initial: true);
  }

  void _hydrateFromSave(GameController game) {
    final save = game.save;
    _currentNodeId = save.currentChatNodeId;
    _currentLocationId = save.lastPingLocationId;
    _signalStrength = save.signalStrength;
    _trustScore = save.trustScore;
    if (save.messageLog.isNotEmpty) {
      _messages
        ..clear()
        ..addAll(
          save.messageLog.map(
            (entry) => ChatMessage(
              sender: MessageSender.values.byName(entry['sender'] as String),
              text: entry['text'] as String,
              timestamp: entry['timestamp'] as String,
              isCorrupted: entry['isCorrupted'] as bool? ?? false,
            ),
          ),
        );
      _introIndex = _seedMessages.length;
      _isLocked = false;
      _isTyping = false;
    } else if (_introIndex == 0 && _messages.isEmpty) {
      _startIntroSequence();
    }
  }

  void _queueNextIntroMessage({bool initial = false}) {
    if (_introIndex >= _seedMessages.length) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _isLocked = false;
        });
      }
      return;
    }

    final delay =
        initial ? const Duration(milliseconds: 600) : const Duration(milliseconds: 1300);
    setState(() {
      _isTyping = true;
      _isLocked = true;
    });

    _introTimer?.cancel();
    _introTimer = Timer(delay, () {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(_seedMessages[_introIndex]);
        _introIndex += 1;
        _isTyping = false;
      });
      _scrollToBottom();
      _persistChatState();

      if (_introIndex < _seedMessages.length) {
        _queueNextIntroMessage();
      } else {
        setState(() {
          _isLocked = false;
        });
      }
    });
  }

  void _handleChoiceTap(int index) {
    final node = _currentNode;
    if (node is _EndingNode) {
      _openMapFromChat();
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
    _persistChatState();

    _replyTimer?.cancel();
    _replyTimer = Timer(_responseDelay, () async {
      if (!mounted) {
        return;
      }

      setState(() {
        _signalStrength =
            (_signalStrength + selectedChoice.signalDelta).clamp(24, 99).toInt();
        _trustScore = (_trustScore + (selectedChoice.signalDelta > -10 ? 4 : -6))
            .clamp(20, 90)
            .toInt();
        _messages.add(selectedChoice.response);
        _isTyping = false;
        _currentNodeId = selectedChoice.nextNodeId;
        _currentLocationId = selectedChoice.locationId;
        final nextNode = _currentNode;
        if (nextNode is _EndingNode) {
          _messages.add(nextNode.finalMessage);
          _isLocked = true;
        } else {
          _isLocked = false;
        }
      });

      _scrollToBottom();
      await _persistChatState();
    });
  }

  Future<void> _openMapFromChat() async {
    await _game?.openMap(
      storyPhase: 'engineering_phase',
      objectiveId: 'recover_engineering',
      lastPingLocationId: _currentLocationId,
      unlockedLocationIds: const <String>['engineering'],
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CampusMapScreen(
          gender: widget.gender,
          signalStrength: _signalStrength,
          trustScore: _trustScore,
        ),
      ),
    );
  }

  Future<void> _persistChatState() {
    return _game?.saveChatState(
          currentNodeId: _currentNodeId,
          storyPhase: _storyPhaseForNode(_currentNodeId),
          lastPingLocationId: _currentLocationId,
          signalStrength: _signalStrength,
          trustScore: _trustScore,
          messages: _messages,
        ) ??
        Future<void>.value();
  }

  String _storyPhaseForNode(String nodeId) {
    if (nodeId.startsWith('dorm') || nodeId == 'entry') {
      return 'chat_dorm';
    }
    if (nodeId.startsWith('engineering')) {
      return 'chat_engineering';
    }
    if (nodeId.startsWith('admin')) {
      return 'chat_admin';
    }
    if (nodeId.startsWith('library')) {
      return 'chat_library';
    }
    return 'chat_basement';
  }

  Duration get _responseDelay {
    if (_signalStrength <= 40) {
      return const Duration(milliseconds: 1700);
    }
    if (_signalStrength <= 60) {
      return const Duration(milliseconds: 1350);
    }
    return const Duration(milliseconds: 1000);
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
    final minute = 15 + (_messages.length ~/ 2);
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.asset(
                  _backgroundImagePath,
                  key: ValueKey(_backgroundImagePath),
                  fit: BoxFit.cover,
                ),
              ),
              Container(color: Colors.black.withValues(alpha: 0.86)),
              Opacity(
                opacity: 0.14,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF7CFF41).withValues(alpha: 0.28),
                    BlendMode.screen,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset(
                      _backgroundImagePath,
                      key: ValueKey('tint-$_backgroundImagePath'),
                      fit: BoxFit.cover,
                    ),
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
                          decoration:
                              _chatPanelDecoration(radius: isCompact ? 14 : 0),
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
                                            _backgroundImagePath,
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
                                      separatorBuilder: (_, _) => SizedBox(
                                        height: isCompact ? 10 : 14,
                                      ),
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
                                        child: _TypingIndicator(
                                          compact: isCompact,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 1,
                                color: const Color(0xFF7CFF41)
                                    .withValues(alpha: 0.28),
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
                                          bottom:
                                              index == _visibleChoices.length - 1
                                                  ? 0
                                                  : (isCompact ? 8 : 12),
                                        ),
                                        child: _ResponseOption(
                                          text: _visibleChoices[index],
                                          compact: isCompact,
                                          disabled: _isLocked &&
                                              _currentNode is! _EndingNode,
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
                Text(
                  'LAST PING: ${_locationLabels[_currentLocationId] ?? 'UNKNOWN'}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isCompact ? 10 : 12,
                    letterSpacing: isCompact ? 1.0 : 1.5,
                  ),
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
                  _messages.isEmpty ? '--:--' : _messages.last.timestamp,
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

  String get _backgroundImagePath =>
      _locationBackgrounds[_currentLocationId] ?? 'assets/images/corridor.png';
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
    required this.locationId,
    required this.response,
  });

  final String text;
  final int signalDelta;
  final String nextNodeId;
  final String locationId;
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
              color:
                  isPlayer ? const Color(0xFFB8FFD8) : const Color(0xFF7CFF41),
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
