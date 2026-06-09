import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lost_signal/features/chat/screens/chat_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  static const List<_MenuEntry> _items = [
    _MenuEntry(title: 'CONTINUE', subtitle: 'Resume your last session'),
    _MenuEntry(title: 'CHAT', subtitle: 'Open the live channel'),
    _MenuEntry(title: 'NEW GAME', subtitle: 'Start a new transmission'),
    _MenuEntry(title: 'SETTINGS', subtitle: 'Audio, Graphics, Controls'),
    _MenuEntry(title: 'ABOUT', subtitle: 'About Lost Signal'),
  ];

  static const List<String> _statuses = [
    'SIGNAL STABLE',
    'SIGNAL UNSTABLE',
    'UNKNOWN CONNECTION DETECTED',
  ];

  late final AnimationController _backgroundController;
  late final AudioPlayer _humPlayer;
  late final AudioPlayer _cracklePlayer;
  late final AudioPlayer _beepPlayer;
  final math.Random _random = math.Random();

  Timer? _glitchTimer;
  Timer? _statusTimer;
  Timer? _crackleTimer;

  int _selectedIndex = 0;
  int _statusIndex = 0;
  bool _glitchOffset = false;
  bool _statusOverride = false;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _humPlayer = AudioPlayer();
    _cracklePlayer = AudioPlayer();
    _beepPlayer = AudioPlayer();
    _startAmbientAudio();
    _scheduleStatusShift();
    _scheduleCrackle();

    _glitchTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _glitchOffset = true;
      });
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _glitchOffset = false;
        });
      });
    });
  }

  Future<void> _startAmbientAudio() async {
    await _humPlayer.setReleaseMode(ReleaseMode.loop);
    await _humPlayer.setVolume(0.12);
    await _humPlayer.play(AssetSource('sounds/ambient_hum.mp3'));
  }

  void _scheduleCrackle() {
    final delay = Duration(seconds: 20 + _random.nextInt(11));
    _crackleTimer = Timer(delay, () async {
      if (!mounted) {
        return;
      }
      await _cracklePlayer.setVolume(0.16);
      await _cracklePlayer.play(AssetSource('sounds/radio_static.mp3'));
      _scheduleCrackle();
    });
  }

  void _scheduleStatusShift() {
    final delay = Duration(seconds: 5 + _random.nextInt(3));
    _statusTimer = Timer(delay, () {
      if (!mounted) {
        return;
      }
      final shouldOverride = _random.nextBool();
      setState(() {
        _statusOverride = shouldOverride;
        _statusIndex = shouldOverride ? 1 + _random.nextInt(2) : 0;
      });
      if (shouldOverride) {
        Future<void>.delayed(const Duration(seconds: 2), () {
          if (!mounted) {
            return;
          }
          setState(() {
            _statusOverride = false;
            _statusIndex = 0;
          });
        });
      }
      _scheduleStatusShift();
    });
  }

  Future<void> _playMenuBeep() async {
    await _beepPlayer.stop();
    await _beepPlayer.setVolume(0.12);
    await _beepPlayer.play(AssetSource('sounds/menu_change.mp3'));
  }

  void _selectIndex(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    unawaited(_playMenuBeep());
  }

  void _handleMenuTap(int index) {
    _selectIndex(index);
    if (_items[index].title == 'CHAT') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const ChatScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    _statusTimer?.cancel();
    _crackleTimer?.cancel();
    _backgroundController.dispose();
    _humPlayer.dispose();
    _cracklePlayer.dispose();
    _beepPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(),
              const _MenuScanlines(),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 14 : 24,
                    isCompact ? 14 : 20,
                    isCompact ? 14 : 24,
                    isCompact ? 14 : 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 780),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTopHud(isCompact),
                          SizedBox(height: isCompact ? 14 : 26),
                          _buildLogo(isCompact),
                          SizedBox(height: isCompact ? 8 : 14),
                          _buildSignalPanel(isCompact),
                          SizedBox(height: isCompact ? 12 : 22),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_items.length, (index) {
                                final item = _items[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: index == _items.length - 1 ? 0 : (isCompact ? 8 : 12)),
                                  child: _MenuCard(
                                    entry: item,
                                    selected: index == _selectedIndex,
                                    glitchOffset: _glitchOffset,
                                    compact: isCompact,
                                    onTap: () => _handleMenuTap(index),
                                    onHover: () => _selectIndex(index),
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: isCompact ? 12 : 20),
                          _buildBottomHud(isCompact),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            final t = _backgroundController.value;
            final scale = 1.02 + (t * 0.03);
            final shiftY = -8 + (t * 16);

            return Transform.translate(
              offset: Offset(0, shiftY),
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/corridor.png', fit: BoxFit.cover),
              Container(color: Colors.black.withValues(alpha: 0.48)),
              Opacity(
                opacity: 0.22,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF7CFF41).withValues(alpha: 0.24),
                    BlendMode.screen,
                  ),
                  child: Image.asset('assets/images/corridor.png', fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.14),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.22),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHud(bool isCompact) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: isCompact ? 12 : 14),
            decoration: _hudDecoration(),
            child: Row(
              children: [
                Icon(
                  Icons.settings_input_antenna,
                  color: const Color(0xFF7CFF41),
                  size: isCompact ? 24 : 30,
                ),
                SizedBox(width: isCompact ? 10 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _hudText('NETWORK: UNKNOWN', compact: isCompact),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: 'CONNECTION: ', style: _hudStyle(compact: isCompact)),
                            TextSpan(text: 'SECURE', style: _hudStyle(compact: isCompact, green: true)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      _hudText('USER: UNKNOWN', compact: isCompact),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: isCompact ? 10 : 14),
        _HudIconButton(compact: isCompact),
      ],
    );
  }

  Widget _buildLogo(bool isCompact) {
    final width = isCompact ? 180.0 : 320.0;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_glitchOffset)
            Transform.translate(
              offset: const Offset(-5, 0),
              child: Opacity(
                opacity: 0.2,
                child: Image.asset('assets/images/lost_signal_logo.png', width: width, fit: BoxFit.contain),
              ),
            ),
          Transform.translate(
            offset: _glitchOffset ? const Offset(5, 0) : Offset.zero,
            child: Image.asset('assets/images/lost_signal_logo.png', width: width, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalPanel(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 18, vertical: isCompact ? 12 : 14),
      decoration: _hudDecoration(),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(
                    '${_statuses[_statusIndex]}  •  87%',
                    key: ValueKey(_statuses[_statusIndex]),
                    style: TextStyle(
                      color: _statusOverride ? const Color(0xFFB8FFD8) : Colors.white,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Align(alignment: Alignment.centerRight, child: _PulseLine(compact: true)),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: Text(
                      '${_statuses[_statusIndex]}  •  87%',
                      key: ValueKey(_statuses[_statusIndex]),
                      style: TextStyle(
                        color: _statusOverride ? const Color(0xFFB8FFD8) : Colors.white,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                const _PulseLine(),
              ],
            ),
    );
  }

  Widget _buildBottomHud(bool isCompact) {
    return isCompact
        ? Column(
            children: const [
              _BottomInfoCard(compact: true),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _WaveCard(compact: true)),
                  SizedBox(width: 8),
                  Expanded(child: _SignalStrengthCard(compact: true)),
                ],
              ),
            ],
          )
        : Row(
            children: const [
              Expanded(flex: 3, child: _BottomInfoCard()),
              SizedBox(width: 12),
              Expanded(flex: 2, child: _WaveCard()),
              SizedBox(width: 12),
              Expanded(flex: 4, child: _SignalStrengthCard()),
            ],
          );
  }

  Text _hudText(String text, {required bool compact}) {
    return Text(text, style: _hudStyle(compact: compact));
  }

  TextStyle _hudStyle({required bool compact, bool green = false}) {
    return TextStyle(
      color: green ? const Color(0xFF7CFF41) : Colors.white,
      fontSize: compact ? 11 : 13,
      letterSpacing: compact ? 1.2 : 1.6,
    );
  }
}

class _MenuEntry {
  const _MenuEntry({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.entry,
    required this.selected,
    required this.glitchOffset,
    required this.compact,
    required this.onTap,
    required this.onHover,
  });

  final _MenuEntry entry;
  final bool selected;
  final bool glitchOffset;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: GestureDetector(
        onTap: onTap,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 20,
            vertical: compact ? 10 : 18,
          ),
          decoration: _hudDecoration(selected: selected, glow: selected ? 0.22 : 0.08),
          child: Row(
            children: [
              Icon(
                Icons.play_arrow_rounded,
                size: compact ? 26 : 34,
                color: const Color(0xFFEAFAEA),
              ),
              SizedBox(width: compact ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        if (selected && glitchOffset)
                          Transform.translate(
                            offset: const Offset(-2, 0),
                            child: Text(
                              entry.title,
                              style: TextStyle(
                                color: const Color(0xFF7CFF41).withValues(alpha: 0.25),
                                fontSize: compact ? 16 : 24,
                                letterSpacing: compact ? 1.6 : 2.2,
                              ),
                            ),
                          ),
                        Text(
                          entry.title,
                          style: TextStyle(
                            color: const Color(0xFFEAFAEA),
                            fontSize: compact ? 16 : 24,
                            letterSpacing: compact ? 1.4 : 2.2,
                          ),
                        ),
                      ],
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      Text(
                        entry.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: compact ? 8 : 12),
              Icon(
                Icons.play_arrow_rounded,
                size: compact ? 26 : 34,
                color: const Color(0xFF7CFF41).withValues(alpha: selected ? 1 : 0.78),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HudIconButton extends StatelessWidget {
  const _HudIconButton({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 48.0 : 62.0;
    return Container(
      width: size,
      height: size,
      decoration: _hudDecoration(),
      child: Icon(
        Icons.volume_up_outlined,
        color: const Color(0xFF7CFF41),
        size: compact ? 22 : 30,
      ),
    );
  }
}

class _PulseLine extends StatelessWidget {
  const _PulseLine({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 84 : 110,
      height: compact ? 18 : 22,
      child: CustomPaint(painter: _PulseLinePainter()),
    );
  }
}

class _PulseLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7CFF41)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width * 0.18, size.height * 0.55)
      ..lineTo(size.width * 0.26, size.height * 0.48)
      ..lineTo(size.width * 0.34, size.height * 0.56)
      ..lineTo(size.width * 0.44, size.height * 0.54)
      ..lineTo(size.width * 0.55, size.height * 0.2)
      ..lineTo(size.width * 0.63, size.height * 0.78)
      ..lineTo(size.width * 0.73, size.height * 0.52)
      ..lineTo(size.width, size.height * 0.55);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomInfoCard extends StatelessWidget {
  const _BottomInfoCard({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 118 : 132,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: _hudDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAST TRANSMISSION:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: compact ? 10 : 12,
              letterSpacing: compact ? 1.2 : 1.6,
            ),
          ),
          const Spacer(),
          Text(
            '2:13 AM',
            style: TextStyle(
              color: const Color(0xFFEAFAEA),
              fontSize: compact ? 18 : 28,
              letterSpacing: compact ? 2.0 : 2.6,
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            'DATE: 23/05/2025',
            style: TextStyle(
              color: const Color(0xFF7CFF41),
              fontSize: compact ? 10 : 12,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveCard extends StatelessWidget {
  const _WaveCard({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 118 : 132,
      decoration: _hudDecoration(),
      child: Center(
        child: SizedBox(
          width: compact ? 76 : 120,
          height: compact ? 36 : 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(18, (index) {
              final heights = compact
                  ? [4.0, 8.0, 10.0, 14.0, 16.0, 12.0]
                  : [8.0, 12.0, 18.0, 24.0, 30.0, 20.0];
              return Container(
                width: compact ? 2.5 : 3,
                height: heights[index % heights.length],
                color: const Color(0xFF7CFF41),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SignalStrengthCard extends StatelessWidget {
  const _SignalStrengthCard({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 118 : 132,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: _hudDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIGNAL STRENGTH:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: compact ? 10 : 12,
              letterSpacing: compact ? 1.2 : 1.6,
            ),
          ),
          SizedBox(height: compact ? 10 : 14),
          Wrap(
            spacing: 4,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...List.generate(12, (index) {
                final active = index < 10;
                return Container(
                  width: compact ? 10 : 14,
                  height: compact ? 14 : 22,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF7CFF41) : Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFF7CFF41).withValues(alpha: active ? 0 : 0.55),
                    ),
                  ),
                );
              }),
              Padding(
                padding: EdgeInsets.only(left: compact ? 4 : 10),
                child: Text(
                  '87%',
                  style: TextStyle(
                    color: const Color(0xFF7CFF41),
                    fontSize: compact ? 16 : 22,
                    letterSpacing: 2.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 6 : 12),
          Text(
            'STATUS: ONLINE \u25cf',
            style: TextStyle(
              color: const Color(0xFF7CFF41),
              fontSize: compact ? 9 : 12,
              letterSpacing: compact ? 1.0 : 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuScanlines extends StatelessWidget {
  const _MenuScanlines();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _MenuScanlinePainter(),
        child: Container(),
      ),
    );
  }
}

class _MenuScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF7CFF41).withValues(alpha: 0.03)
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
        stops: const [0.45, 1],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

BoxDecoration _hudDecoration({bool selected = false, double glow = 0.08}) {
  return BoxDecoration(
    border: Border.all(
      color: const Color(0xFF7CFF41).withValues(alpha: selected ? 0.64 : 0.34),
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF7CFF41).withValues(alpha: glow),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
    gradient: LinearGradient(
      colors: [
        const Color(0xFF7CFF41).withValues(alpha: selected ? 0.14 : 0.05),
        Colors.black.withValues(alpha: 0.34),
      ],
    ),
  );
}
