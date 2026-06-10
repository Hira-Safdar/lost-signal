import 'package:flutter/material.dart';
import 'package:lost_signal/shared/game/game_controller.dart';

import '../models/player_profile.dart';

class EndingScreen extends StatelessWidget {
  const EndingScreen({
    super.key,
    required this.gender,
    required this.signalStrength,
    required this.trustScore,
    required this.clueCount,
  });

  final PlayerGender gender;
  final int signalStrength;
  final int trustScore;
  final int clueCount;

  bool get _goodEnding => signalStrength >= 55 && trustScore >= 55 && clueCount >= 5;

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final title = _goodEnding ? 'ENDING: SIGNAL HELD' : 'ENDING: TOO LATE';
    final body = _goodEnding
        ? '${gender.subject} reached Room 207 with Nathan Kim\'s ID, the missing report, his broken phone draft, the dorm access card, and the basement key. The evidence proved Nathan was lured across campus and that the real answer lies below the university.'
        : '${gender.subject} pieced together only part of Nathan Kim\'s route. Without the full evidence chain, the signal collapsed, Room 207 went dark, and the way into the basement was lost.';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/corridor.png', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.88)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: _panelDecoration(glow: 0.14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF7CFF41),
                            fontSize: 18,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          body,
                          style: const TextStyle(
                            color: Color(0xFFEAFAEA),
                            fontSize: 18,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: _panelDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Signal: $signalStrength%', style: _statStyle()),
                        const SizedBox(height: 8),
                        Text('Trust: $trustScore%', style: _statStyle()),
                        const SizedBox(height: 8),
                        Text('Clues Found: $clueCount / 5', style: _statStyle()),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await game.replayChapter();
                            if (context.mounted) {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            decoration: _panelDecoration(glow: 0.12),
                            child: const Row(
                              children: [
                                Icon(Icons.refresh_rounded, color: Color(0xFF7CFF41), size: 24),
                                SizedBox(width: 10),
                                Text(
                                  'REPLAY',
                                  style: TextStyle(
                                    color: Color(0xFFEAFAEA),
                                    fontSize: 16,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            decoration: _panelDecoration(glow: 0.12),
                            child: const Row(
                              children: [
                                Icon(Icons.home_rounded, color: Color(0xFF7CFF41), size: 24),
                                SizedBox(width: 10),
                                Text(
                                  'MAIN MENU',
                                  style: TextStyle(
                                    color: Color(0xFFEAFAEA),
                                    fontSize: 16,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _statStyle() {
    return const TextStyle(
      color: Color(0xFFBFFF9A),
      fontSize: 15,
      height: 1.25,
    );
  }
}

BoxDecoration _panelDecoration({double glow = 0.08}) {
  return BoxDecoration(
    border: Border.all(color: const Color(0xFF7CFF41).withValues(alpha: 0.34)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF7CFF41).withValues(alpha: glow),
        blurRadius: 16,
      ),
    ],
    color: const Color(0xFF020502).withValues(alpha: 0.84),
  );
}
