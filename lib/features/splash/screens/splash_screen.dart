import 'dart:async';

import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _fullText = 'Searching for connection...';

  Timer? _typingTimer;
  Timer? _glitchTimer;
  int _visibleCount = 0;
  bool _glitchOn = false;

  @override
  void initState() {
    super.initState();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 65), (timer) {
      if (!mounted) {
        return;
      }
      if (_visibleCount >= _fullText.length) {
        timer.cancel();
        return;
      }
      setState(() {
        _visibleCount++;
      });
    });

    _glitchTimer = Timer.periodic(const Duration(milliseconds: 220), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _glitchOn = !_glitchOn;
      });
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _glitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typedText = _fullText.substring(0, _visibleCount);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_glitchOn)
                      Transform.translate(
                        offset: const Offset(-2, 0),
                        child: const Text(
                          'LOST SIGNAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0x6600FF66),
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    Transform.translate(
                      offset: _glitchOn ? const Offset(2, 0) : Offset.zero,
                      child: const Text(
                        'LOST SIGNAL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.signalGreen,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '$typedText${_showCursor ? '_' : ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.signalGreen,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _showCursor => _glitchOn || _visibleCount < _fullText.length;
}
