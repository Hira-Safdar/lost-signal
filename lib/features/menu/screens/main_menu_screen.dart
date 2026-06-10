import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lost_signal/features/about/screens/about_screen.dart';
import 'package:lost_signal/features/chat/screens/chat_screen.dart';
import 'package:lost_signal/features/settings/screens/settings_screen.dart';
import 'package:lost_signal/features/story/screens/campus_map_screen.dart';
import 'package:lost_signal/features/story/screens/case_file_screen.dart';
import 'package:lost_signal/features/story/screens/character_select_screen.dart';
import 'package:lost_signal/features/story/screens/chapter_intro_screen.dart';
import 'package:lost_signal/features/story/screens/ending_screen.dart';
import 'package:lost_signal/features/story/models/player_profile.dart';
import 'package:lost_signal/shared/settings/app_settings.dart';
import 'package:lost_signal/shared/game/game_controller.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  static const List<_MenuEntry> _items = [
    _MenuEntry(
      title: 'CONTINUE',
      subtitle: 'Resume your last session',
      icon: Icons.play_arrow_rounded,
    ),
    _MenuEntry(
      title: 'NEW GAME',
      subtitle: 'Start a new transmission',
      icon: Icons.videogame_asset_outlined,
    ),
    _MenuEntry(
      title: 'SETTINGS',
      subtitle: 'Audio, Graphics, Controls',
      icon: Icons.settings_outlined,
    ),
    _MenuEntry(
      title: 'ABOUT',
      subtitle: 'About Lost Signal',
      icon: Icons.info_outline_rounded,
    ),
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
  bool _isMuted = false;
  AppSettingsController? _settings;

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
      if (!(_settings?.glitchEffectsEnabled ?? true)) {
        return;
      }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextSettings = AppSettingsScope.of(context);
    if (!identical(_settings, nextSettings)) {
      _settings?.removeListener(_applySettings);
      _settings = nextSettings;
      _settings!.addListener(_applySettings);
      _applySettings();
    }
  }

  Future<void> _startAmbientAudio() async {
    await _humPlayer.setReleaseMode(ReleaseMode.loop);
    await _humPlayer.play(AssetSource('sounds/ambient_hum.mp3'));
    _applySettings();
  }

  Future<void> _applySettings() async {
    final settings = _settings;
    if (settings == null) {
      return;
    }
    final ambientVolume = _isMuted ? 0.0 : (settings.ambientMix * 0.22).clamp(0.0, 1.0);
    final effectsVolume = _isMuted ? 0.0 : (settings.effectsMix * 0.18).clamp(0.0, 1.0);
    await _humPlayer.setVolume(ambientVolume);
    await _cracklePlayer.setVolume(effectsVolume);
    await _beepPlayer.setVolume(effectsVolume);
  }

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    await _applySettings();
  }

  void _scheduleCrackle() {
    final delay = Duration(seconds: 20 + _random.nextInt(11));
    _crackleTimer = Timer(delay, () async {
      if (!mounted) {
        return;
      }
      if (_settings?.glitchEffectsEnabled ?? true) {
        await _cracklePlayer.play(AssetSource('sounds/radio_static.mp3'));
      }
      _scheduleCrackle();
    });
  }

  void _scheduleStatusShift() {
    final delay = Duration(seconds: 5 + _random.nextInt(3));
    _statusTimer = Timer(delay, () {
      if (!mounted) {
        return;
      }
      final glitchEnabled = _settings?.glitchEffectsEnabled ?? true;
      final shouldOverride = glitchEnabled && _random.nextBool();
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
    await _applySettings();
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
    if (_items[index].title == 'NEW GAME') {
      _startNewGame();
    } else if (_items[index].title == 'CONTINUE') {
      _continueGame();
    } else if (_items[index].title == 'SETTINGS') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SettingsScreen(),
        ),
      );
    } else if (_items[index].title == 'ABOUT') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const AboutScreen(),
        ),
      );
    }
  }

  Future<void> _startNewGame() async {
    final game = GameScope.read(context);
    await game.startNewGame();
    if (!mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CharacterSelectScreen(),
      ),
    );
  }

  void _continueGame() {
    final game = GameScope.read(context);
    if (!game.canContinue && !game.hasEnding) {
      _startNewGame();
      return;
    }

    final save = game.save;
    Widget destination;
    switch (save.currentScreenId) {
      case 'character_select':
        destination = const CharacterSelectScreen();
      case 'chapter_intro':
        destination = ChapterIntroScreen(gender: game.selectedGender ?? PlayerGender.male);
      case 'chat':
        destination = ChatScreen(gender: game.selectedGender ?? PlayerGender.male);
      case 'campus_map':
        destination = CampusMapScreen(
          gender: game.selectedGender ?? PlayerGender.male,
          signalStrength: save.signalStrength,
          trustScore: save.trustScore,
        );
      case 'case_file':
        destination = const CaseFileScreen();
      case 'ending':
        destination = EndingScreen(
          gender: game.selectedGender ?? PlayerGender.male,
          signalStrength: save.signalStrength,
          trustScore: save.trustScore,
          clueCount: save.collectedClueIds.length,
        );
      default:
        destination = const CharacterSelectScreen();
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => destination),
    );
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    _statusTimer?.cancel();
    _crackleTimer?.cancel();
    _settings?.removeListener(_applySettings);
    _backgroundController.dispose();
    _humPlayer.dispose();
    _cracklePlayer.dispose();
    _beepPlayer.dispose();
    super.dispose();
  }

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
              _buildBackground(),
              if (settings.scanlinesEnabled) const _MenuScanlines(),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 14 : 24,
                    isCompact ? 12 : 20,
                    isCompact ? 14 : 24,
                    isCompact ? 8 : 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 780),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTopHud(isCompact),
                          SizedBox(height: isCompact ? 20 : 32),
                          _buildLogo(isCompact),
                          SizedBox(height: isCompact ? 4 : 10),
                          _buildSignalPanel(isCompact),
                          SizedBox(height: isCompact ? 8 : 18),
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isCompact ? 320 : 520,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(_items.length, (index) {
                                    final item = _items[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index == _items.length - 1
                                            ? 0
                                            : (isCompact ? 6 : 12),
                                      ),
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
                            ),
                          ),
                          SizedBox(height: isCompact ? 6 : 16),
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
              Container(color: Colors.black.withValues(alpha: 0.10)),
              Opacity(
                opacity: 0.52,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF7CFF41).withValues(alpha: 0.22),
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
                Colors.black.withValues(alpha: 0.02),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.06),
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
            height: isCompact ? 48 : 62,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 10 : 16,
              vertical: isCompact ? 6 : 10,
            ),
            decoration: _hudDecoration(),
            child: Row(
              children: [
                Icon(
                  Icons.settings_input_antenna,
                  color: const Color(0xFF7CFF41),
                  size: isCompact ? 18 : 26,
                ),
                SizedBox(width: isCompact ? 8 : 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _hudText('NETWORK: UNKNOWN', compact: isCompact),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'CONNECTION: ',
                              style: _hudStyle(compact: isCompact),
                            ),
                            TextSpan(
                              text: 'SECURE',
                              style: _hudStyle(compact: isCompact, green: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: isCompact ? 10 : 14),
        _HudIconButton(
          compact: isCompact,
          isMuted: _isMuted,
          onTap: _toggleMute,
        ),
      ],
    );
  }

  Widget _buildLogo(bool isCompact) {
    final width = isCompact ? 385.0 : 560.0;
    final glitchEnabled = _settings?.glitchEffectsEnabled ?? true;
    return Center(
      child: Transform.translate(
        offset: Offset(0, isCompact ? 14 : 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (glitchEnabled && _glitchOffset)
              Transform.translate(
                offset: const Offset(-5, 0),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/images/lost_signal_logo.png',
                    width: width,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            Transform.translate(
              offset: glitchEnabled && _glitchOffset ? const Offset(5, 0) : Offset.zero,
              child: Image.asset(
                'assets/images/lost_signal_logo.png',
                width: width,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalPanel(bool isCompact) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: Text(
          _statuses[_statusIndex],
          key: ValueKey(_statuses[_statusIndex]),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _statusOverride
                ? const Color(0xFFB8FFD8)
                : const Color(0xFF7CFF41),
            fontSize: isCompact ? 13 : 18,
            letterSpacing: isCompact ? 1.5 : 2.2,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomHud(bool isCompact) {
    return isCompact
        ? const Row(
            children: [
              Expanded(child: _BottomInfoCard(compact: true)),
              SizedBox(width: 8),
              Expanded(child: _SignalStrengthCard(compact: true)),
            ],
          )
        : Row(
            children: const [
              Expanded(flex: 3, child: _BottomInfoCard()),
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
      fontSize: compact ? 10 : 13,
      letterSpacing: compact ? 1.0 : 1.6,
    );
  }
}

class _MenuEntry {
  const _MenuEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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
    final glitchEnabled = AppSettingsScope.of(context).glitchEffectsEnabled;
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 20,
            vertical: compact ? 9 : 18,
          ),
          decoration: _hudDecoration(
            selected: selected,
            glow: selected ? 0.22 : 0.08,
            radius: compact ? 14 : 18,
          ),
          child: Row(
            children: [
              Icon(
                entry.icon,
                size: compact ? 22 : 34,
                color: const Color(0xFFEAFAEA),
              ),
              SizedBox(width: compact ? 8 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        if (selected && glitchOffset && glitchEnabled)
                          Transform.translate(
                            offset: const Offset(-2, 0),
                            child: Text(
                              entry.title,
                              style: TextStyle(
                                color: const Color(0xFF7CFF41).withValues(alpha: 0.25),
                                fontSize: compact ? 16 : 24,
                                letterSpacing: compact ? 1.3 : 2.2,
                              ),
                            ),
                          ),
                        Text(
                          entry.title,
                          style: TextStyle(
                            color: const Color(0xFFEAFAEA),
                            fontSize: compact ? 16 : 24,
                            letterSpacing: compact ? 1.3 : 2.2,
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
              SizedBox(width: compact ? 6 : 12),
              Icon(
                entry.icon,
                size: compact ? 22 : 34,
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
  const _HudIconButton({
    required this.compact,
    required this.isMuted,
    required this.onTap,
  });

  final bool compact;
  final bool isMuted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 48.0 : 62.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: _hudDecoration(selected: !isMuted, glow: !isMuted ? 0.12 : 0.05),
        child: Icon(
          isMuted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
          color: const Color(0xFF7CFF41),
          size: compact ? 22 : 30,
        ),
      ),
    );
  }
}

class _BottomInfoCard extends StatelessWidget {
  const _BottomInfoCard({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 76 : 112,
      padding: EdgeInsets.all(compact ? 9 : 14),
      decoration: _hudDecoration(radius: compact ? 12 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAST TRANSMISSION:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: compact ? 9 : 12,
              letterSpacing: compact ? 1.0 : 1.6,
            ),
          ),
          SizedBox(height: compact ? 4 : 10),
          Text(
            '2:13 AM',
            style: TextStyle(
              color: const Color(0xFFEAFAEA),
              fontSize: compact ? 16 : 28,
              letterSpacing: compact ? 1.2 : 2.6,
            ),
          ),
          SizedBox(height: compact ? 2 : 8),
          Text(
            'DATE: 23/05/2025',
            style: TextStyle(
              color: const Color(0xFF7CFF41),
              fontSize: compact ? 7 : 12,
              letterSpacing: compact ? 0.8 : 1.4,
            ),
          ),
        ],
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
      height: compact ? 76 : 112,
      padding: EdgeInsets.all(compact ? 9 : 14),
      decoration: _hudDecoration(radius: compact ? 12 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIGNAL STRENGTH:',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: compact ? 9 : 12,
              letterSpacing: compact ? 1.0 : 1.6,
            ),
          ),
          SizedBox(height: compact ? 6 : 12),
          Wrap(
            spacing: compact ? 3 : 4,
            runSpacing: compact ? 4 : 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...List.generate(12, (index) {
                final active = index < 10;
                return Container(
                  width: compact ? 7 : 14,
                  height: compact ? 10 : 22,
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
                    fontSize: compact ? 12 : 22,
                    letterSpacing: compact ? 1.0 : 2.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 2 : 10),
          Text(
            'STATUS: ONLINE \u25cf',
            style: TextStyle(
              color: const Color(0xFF7CFF41),
              fontSize: compact ? 7 : 12,
              letterSpacing: compact ? 0.6 : 1.4,
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

BoxDecoration _hudDecoration({
  bool selected = false,
  double glow = 0.08,
  double radius = 0,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
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
