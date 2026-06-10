import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _AboutHeader(onBack: () => Navigator.of(context).pop()),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: _panelDecoration(glow: 0.12),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LOST SIGNAL',
                                style: TextStyle(
                                  color: Color(0xFF7CFF41),
                                  fontSize: 18,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'A story-driven psychological horror mystery set inside a university campus where a late-night message pulls the player into a changing, hostile environment.',
                                style: TextStyle(
                                  color: Color(0xFFEAFAEA),
                                  fontSize: 15,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (isWide)
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  title: 'GAMEPLAY LOOP',
                                  lines: [
                                    'Receive messages from an unknown student',
                                    'Reply and affect signal, trust, and story flow',
                                    'Explore campus locations and collect evidence',
                                    'Unlock different outcomes based on your choices',
                                  ],
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: _InfoCard(
                                  title: 'CHAPTER 1 MVP',
                                  lines: [
                                    'Character Select',
                                    'Chapter Intro',
                                    'Interactive Chat',
                                    'Campus Map',
                                    'Searchable Locations',
                                    'Clue Collection',
                                    'Multiple Endings',
                                  ],
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: _InfoCard(
                                  title: 'DESIGN GOAL',
                                  lines: [
                                    'Tension through atmosphere, mystery, and corrupted communication',
                                    'No dependency on jump scares',
                                    'Dark, terminal-like infected UI language',
                                  ],
                                ),
                              ),
                            ],
                          )
                        else ...[
                          const _InfoCard(
                            title: 'GAMEPLAY LOOP',
                            lines: [
                              'Receive messages from an unknown student',
                              'Reply and affect signal, trust, and story flow',
                              'Explore campus locations and collect evidence',
                              'Unlock different outcomes based on your choices',
                            ],
                          ),
                          const SizedBox(height: 14),
                          const _InfoCard(
                            title: 'CHAPTER 1 MVP',
                            lines: [
                              'Character Select',
                              'Chapter Intro',
                              'Interactive Chat',
                              'Campus Map',
                              'Searchable Locations',
                              'Clue Collection',
                              'Multiple Endings',
                            ],
                          ),
                          const SizedBox(height: 14),
                          const _InfoCard(
                            title: 'DESIGN GOAL',
                            lines: [
                              'Tension through atmosphere, mystery, and corrupted communication',
                              'No dependency on jump scares',
                              'Dark, terminal-like infected UI language',
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader({required this.onBack});

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ABOUT',
                  style: TextStyle(
                    color: Color(0xFF7CFF41),
                    fontSize: 18,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Project overview and design direction.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF7CFF41),
              fontSize: 13,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '- $line',
                style: const TextStyle(
                  color: Color(0xFFEAFAEA),
                  fontSize: 14,
                  height: 1.35,
                ),
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
