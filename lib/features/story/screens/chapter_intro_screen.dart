import 'package:flutter/material.dart';

import '../../chat/screens/chat_screen.dart';
import '../models/player_profile.dart';

class ChapterIntroScreen extends StatelessWidget {
  const ChapterIntroScreen({super.key, required this.gender});

  final PlayerGender gender;

  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _panelDecoration(),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHAPTER 1',
                          style: TextStyle(
                            color: Color(0xFF7CFF41),
                            fontSize: 13,
                            letterSpacing: 1.6,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'THE FIRST MESSAGE',
                          style: TextStyle(
                            color: Color(0xFFEAFAEA),
                            fontSize: 26,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: _panelDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${gender.subject} was leaving Gujranwala University when a message arrived from a missing student named Nathan Kim. The texts mention Room 207, a broken route through Engineering Block, and something that began following him after he checked a missing-person report.',
                            style: const TextStyle(
                              color: Color(0xFFEAFAEA),
                              fontSize: 18,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Objective: verify Nathan\'s identity, rebuild his path through the campus, and collect the evidence needed to reach the basement before the signal dies.',
                            style: TextStyle(
                              color: const Color(0xFFBFFF9A),
                              fontSize: 15,
                              height: 1.35,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Each clue should explain one part of Nathan\'s route: who he was, where he went, and why the basement matters.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => ChatScreen(gender: gender),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: _panelDecoration(glow: 0.14),
                      child: const Row(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF7CFF41), size: 24),
                          SizedBox(width: 10),
                          Text(
                            'OPEN FIRST CONTACT',
                            style: TextStyle(
                              color: Color(0xFFEAFAEA),
                              fontSize: 17,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
