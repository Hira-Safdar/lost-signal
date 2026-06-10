import 'package:flutter/material.dart';
import 'package:lost_signal/shared/game/game_controller.dart';

import '../models/player_profile.dart';
import 'chapter_intro_screen.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  PlayerGender _selected = PlayerGender.male;

  String get _selectedName =>
      _selected == PlayerGender.male ? 'Nathan Kim' : 'Sara Raza';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/corridor.png', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.84)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(
                    title: 'CHARACTER SELECT',
                    subtitle: 'Choose who enters the campus tonight.',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _AvatarCard(
                                  label: 'NATHAN KIM',
                                  role: 'Male Lead',
                                  imagePath: 'assets/images/male_character.png',
                                  selected: _selected == PlayerGender.male,
                                  onTap: () => setState(() => _selected = PlayerGender.male),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AvatarCard(
                                  label: 'SARA RAZA',
                                  role: 'Female Lead',
                                  imagePath: 'assets/images/female_character.png',
                                  selected: _selected == PlayerGender.female,
                                  onTap: () => setState(() => _selected = PlayerGender.female),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: _panelDecoration(),
                          child: Text(
                            '$_selectedName entered the hallway after midnight. The signal was already waiting.',
                            style: const TextStyle(
                              color: Color(0xFFBFFF9A),
                              fontSize: 16,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () async {
                      await GameScope.read(context).setCharacter(_selected);
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChapterIntroScreen(gender: _selected),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: _panelDecoration(glow: 0.14),
                      child: const Row(
                        children: [
                          Icon(Icons.play_arrow_rounded, color: Color(0xFF7CFF41), size: 28),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'BEGIN CHAPTER 1',
                              style: TextStyle(
                                color: Color(0xFFEAFAEA),
                                fontSize: 17,
                                letterSpacing: 1.2,
                              ),
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

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({
    required this.label,
    required this.role,
    required this.imagePath,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String role;
  final String imagePath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _panelDecoration(glow: selected ? 0.26 : 0.06, selected: selected),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: _panelDecoration(glow: selected ? 0.18 : 0.04, selected: selected),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.12),
                            Colors.black.withValues(alpha: 0.34),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFFBFFF9A) : const Color(0xFFEAFAEA),
                fontSize: 17,
                letterSpacing: 1.3,
                shadows: selected
                    ? const [Shadow(color: Color(0xCC7CFF41), blurRadius: 16)]
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              role,
              style: TextStyle(
                color: selected ? const Color(0xFF7CFF41) : Colors.white70,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: _panelDecoration(),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF7CFF41),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _panelDecoration({double glow = 0.08, bool selected = false}) {
  return BoxDecoration(
    border: Border.all(
      color: const Color(0xFF7CFF41).withValues(alpha: selected ? 0.84 : 0.34),
      width: selected ? 1.6 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF7CFF41).withValues(alpha: glow),
        blurRadius: 16,
      ),
    ],
    color: const Color(0xFF020502).withValues(alpha: 0.84),
  );
}
