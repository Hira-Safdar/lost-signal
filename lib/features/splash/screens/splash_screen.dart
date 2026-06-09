import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lost_signal/features/menu/screens/main_menu_screen.dart';

import '../../../shared/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _searchText = 'SEARCHING FOR SIGNAL';
  static const List<int> _progressStops = [12, 28, 41, 67, 82];
  static const Duration _tick = Duration(milliseconds: 80);
  static const Duration _blackDuration = Duration(seconds: 1);
  static const Duration _dotDuration = Duration(seconds: 1);
  static const Duration _typingDuration = Duration(seconds: 2);
  static const Duration _scanDuration = Duration(seconds: 2);
  static const Duration _signalFoundDuration = Duration(seconds: 1);
  static const Duration _transitionDuration = Duration(milliseconds: 700);
  static const Duration _glitchDuration = Duration(milliseconds: 180);

  late final AudioPlayer _humPlayer;
  late final AudioPlayer _staticPlayer;
  late final AudioPlayer _sfxPlayer;
  late final AudioPlayer _dotPlayer;
  late final Stopwatch _stopwatch;

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  int _lastTypedLength = 0;
  int _lastProgressIndex = -1;
  bool _glitchPlayed = false;
  bool _signalFoundPlayed = false;
  bool _navigated = false;
  bool _dotClickPlayed = false;

  Duration get _dotStart => _blackDuration;
  Duration get _typingStart => _dotStart + _dotDuration;
  Duration get _scanStart => _typingStart + _typingDuration;
  Duration get _glitchStart => _scanStart + _scanDuration;
  Duration get _signalFoundStart => _glitchStart + _glitchDuration;
  Duration get _transitionStart => _signalFoundStart + _signalFoundDuration;

  @override
  void initState() {
    super.initState();
    _humPlayer = AudioPlayer();
    _staticPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _dotPlayer = AudioPlayer();
    _startAudio();

    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(_tick, (_) {
      if (!mounted) {
        return;
      }

      final nextElapsed = _stopwatch.elapsed;
      _processTimeline(nextElapsed);

      setState(() {
        _elapsed = nextElapsed;
      });
    });
  }

  Future<void> _startAudio() async {
    await _humPlayer.setReleaseMode(ReleaseMode.loop);
    await _staticPlayer.setReleaseMode(ReleaseMode.loop);
    await _humPlayer.setVolume(0.15);
    await _staticPlayer.setVolume(0.1);
    await _humPlayer.play(AssetSource('sounds/ambient_hum.mp3'));
    await _staticPlayer.play(AssetSource('sounds/radio_static.mp3'));
  }

  void _processTimeline(Duration elapsed) {
    final typedLength = _typedSearchText.length;
    if (typedLength > _lastTypedLength) {
      _lastTypedLength = typedLength;
      unawaited(_playTypeTick(volume: 0.08));
    }

    if (!_dotClickPlayed && elapsed >= _dotStart) {
      _dotClickPlayed = true;
      unawaited(_playDotClick());
    }

    final progressIndex = _progressIndex;
    if (progressIndex > _lastProgressIndex) {
      _lastProgressIndex = progressIndex;
      unawaited(_playTypeTick(volume: 0.12));
    }

    if (!_glitchPlayed && elapsed >= _glitchStart) {
      _glitchPlayed = true;
      unawaited(_playGlitch());
    }

    if (!_signalFoundPlayed && elapsed >= _signalFoundStart) {
      _signalFoundPlayed = true;
      unawaited(_sfxPlayer.play(AssetSource('sounds/message_receive.mp3')));
    }

    if (!_navigated && elapsed >= _transitionStart) {
      _navigated = true;
      _goToMainMenu();
    }
  }

  Future<void> _playTypeTick({double volume = 0.1}) async {
    await _sfxPlayer.stop();
    await _sfxPlayer.setVolume(volume);
    await _sfxPlayer.play(AssetSource('sounds/type_tick.mp3'));
  }

  Future<void> _playGlitch() async {
    await _sfxPlayer.stop();
    await _sfxPlayer.setVolume(0.22);
    await _sfxPlayer.play(AssetSource('sounds/glitch_short.mp3'));
  }

  Future<void> _playDotClick() async {
    await _dotPlayer.stop();
    await _dotPlayer.setVolume(0.16);
    await _dotPlayer.play(AssetSource('sounds/menu_change.mp3'));
  }

  void _goToMainMenu() {
    _timer?.cancel();
    _humPlayer.setVolume(0.0);
    _staticPlayer.setVolume(0.0);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: _transitionDuration,
        pageBuilder: (_, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: const MainMenuScreen(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _humPlayer.dispose();
    _staticPlayer.dispose();
    _sfxPlayer.dispose();
    _dotPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stage;
    final showBackground = stage != _SplashStage.black && stage != _SplashStage.dot;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (showBackground) const _CorridorBackdrop(opacity: 0.05),
          const _ScanlineOverlay(),
          if (stage == _SplashStage.dot) _buildDotStage(),
          if (stage == _SplashStage.typing) _buildTypingStage(),
          if (stage == _SplashStage.scan) _buildScanStage(),
          if (stage == _SplashStage.glitch) _buildGlitchStage(),
          if (stage == _SplashStage.signalFound) _buildSignalFoundStage(),
        ],
      ),
    );
  }

  Widget _buildDotStage() {
    final localMs = (_elapsed - _dotStart).inMilliseconds;
    final blinkOn = ((localMs / 240).floor() % 2) == 0;

    return Center(
      child: AnimatedOpacity(
        opacity: blinkOn ? 1 : 0.05,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppTheme.signalGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xCC7CFF41),
                blurRadius: 18,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingStage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Text(
          '$_typedSearchText${_showCursor ? "_" : ""}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.signalGreen,
            fontSize: 28,
            letterSpacing: 1.5,
            height: 1.15,
          ),
        ),
      ),
    );
  }

  Widget _buildScanStage() {
    final percent = _progressStops[_progressIndex.clamp(0, _progressStops.length - 1)];
    final filledBlocks = ((percent / 100) * 10).round().clamp(0, 10);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_searchText...',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.signalGreen,
                fontSize: 26,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _buildBar(filledBlocks),
              style: const TextStyle(
                color: AppTheme.signalGreen,
                fontSize: 24,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$percent%',
              style: const TextStyle(
                color: AppTheme.signalGreen,
                fontSize: 20,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlitchStage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _CorridorBackdrop(opacity: 0.08, heavy: true),
        const _GlitchLinesOverlay(),
        Center(
          child: Text(
            'HELP ME',
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 34,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
              shadows: const [
                Shadow(
                  color: Color(0xAAFF3B3B),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignalFoundStage() {
    return const Center(
      child: Text(
        'SIGNAL FOUND',
        style: TextStyle(
          color: AppTheme.signalGreen,
          fontSize: 28,
          letterSpacing: 2.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _SplashStage get _stage {
    if (_elapsed < _blackDuration) {
      return _SplashStage.black;
    }
    if (_elapsed < _typingStart) {
      return _SplashStage.dot;
    }
    if (_elapsed < _scanStart) {
      return _SplashStage.typing;
    }
    if (_elapsed < _glitchStart) {
      return _SplashStage.scan;
    }
    if (_elapsed < _signalFoundStart) {
      return _SplashStage.glitch;
    }
    return _SplashStage.signalFound;
  }

  String get _typedSearchText {
    final local = _elapsed - _typingStart;
    final progress = local.inMilliseconds / _typingDuration.inMilliseconds;
    final visible = (progress * _searchText.length).floor().clamp(0, _searchText.length);
    return _searchText.substring(0, visible);
  }

  int get _progressIndex {
    final local = _elapsed - _scanStart;
    final progress = (local.inMilliseconds / _scanDuration.inMilliseconds).clamp(0.0, 0.999);
    return (progress * _progressStops.length).floor();
  }

  bool get _showCursor => ((_elapsed.inMilliseconds ~/ 220) % 2) == 0;

  String _buildBar(int filledBlocks) {
    const total = 10;
    final filled = '\u2588' * filledBlocks;
    final empty = '\u2591' * (total - filledBlocks);
    return '$filled$empty';
  }
}

enum _SplashStage {
  black,
  dot,
  typing,
  scan,
  glitch,
  signalFound,
}

class _CorridorBackdrop extends StatelessWidget {
  const _CorridorBackdrop({
    this.opacity = 0.05,
    this.heavy = false,
  });

  final double opacity;
  final bool heavy;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          heavy
              ? const Color(0xFF7CFF41).withValues(alpha: 0.28)
              : const Color(0xFF7CFF41).withValues(alpha: 0.12),
          BlendMode.screen,
        ),
        child: Image.asset(
          'assets/images/corridor.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ScanlineOverlay extends StatelessWidget {
  const _ScanlineOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ScanlinePainter(),
        child: Container(),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanPaint = Paint()
      ..color = const Color(0xFF7CFF41).withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanPaint);
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.68),
        ],
        stops: const [0.58, 1],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlitchLinesOverlay extends StatelessWidget {
  const _GlitchLinesOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GlitchPainter(),
        child: Container(),
      ),
    );
  }
}

class _GlitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()
      ..color = const Color(0xFF7CFF41).withValues(alpha: 0.18)
      ..strokeWidth = 1.4;
    final white = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    for (var i = 0; i < 18; i++) {
      final y = size.height * (0.08 + i * 0.045);
      final startX = size.width * (0.02 + (i % 4) * 0.14);
      final endX = startX + size.width * (0.18 + (i % 3) * 0.14);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), i.isEven ? green : white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
