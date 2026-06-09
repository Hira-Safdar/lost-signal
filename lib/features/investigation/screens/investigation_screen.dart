import 'package:flutter/material.dart';

class InvestigationScreen extends StatelessWidget {
  const InvestigationScreen({super.key});

  static const List<_CampusLocation> _locations = [
    _CampusLocation(
      title: 'ENGINEERING BLOCK',
      subtitle: 'Last signal ping detected near Room 207.',
      status: 'HIGH PRIORITY',
      clueCount: 3,
      icon: Icons.apartment_rounded,
    ),
    _CampusLocation(
      title: 'CENTRAL LIBRARY',
      subtitle: 'Archive logs and late-night entry records.',
      status: 'LOCKED ARCHIVE',
      clueCount: 2,
      icon: Icons.local_library_outlined,
    ),
    _CampusLocation(
      title: 'DORMITORIES',
      subtitle: 'Unknown student may have left personal evidence here.',
      status: 'LOW SIGNAL',
      clueCount: 4,
      icon: Icons.meeting_room_outlined,
    ),
    _CampusLocation(
      title: 'ADMIN BLOCK',
      subtitle: 'Security feeds and restricted maintenance reports.',
      status: 'ACCESS DENIED',
      clueCount: 1,
      icon: Icons.domain_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/corridor.png',
                fit: BoxFit.cover,
              ),
              Container(color: Colors.black.withValues(alpha: 0.76)),
              Opacity(
                opacity: 0.16,
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
              const _InvestigationScanlines(),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 12 : 24,
                    isCompact ? 12 : 20,
                    isCompact ? 12 : 24,
                    isCompact ? 12 : 20,
                  ),
                  child: Column(
                    children: [
                      _TopBar(compact: isCompact),
                      SizedBox(height: isCompact ? 12 : 18),
                      Expanded(
                        child: isCompact
                            ? Column(
                                children: [
                                  _MissionPanel(compact: true),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: _locations.length,
                                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        return _LocationCard(
                                          location: _locations[index],
                                          compact: true,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  const Expanded(
                                    flex: 4,
                                    child: _MissionPanel(),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    flex: 6,
                                    child: ListView.separated(
                                      itemCount: _locations.length,
                                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        return _LocationCard(
                                          location: _locations[index],
                                          compact: false,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      SizedBox(height: isCompact ? 10 : 16),
                      _BottomBar(compact: isCompact),
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
}

class _CampusLocation {
  const _CampusLocation({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.clueCount,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String status;
  final int clueCount;
  final IconData icon;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 18,
        vertical: compact ? 10 : 14,
      ),
      decoration: _panelDecoration(radius: compact ? 14 : 0),
      child: Row(
        children: [
          _IconShell(
            icon: Icons.arrow_back_ios_new,
            compact: compact,
            onTap: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: compact ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CAMPUS INVESTIGATION',
                  style: TextStyle(
                    color: const Color(0xFF7CFF41),
                    fontSize: compact ? 14 : 18,
                    letterSpacing: compact ? 1.2 : 2.0,
                  ),
                ),
                SizedBox(height: compact ? 2 : 4),
                Text(
                  'ACTIVE ZONE: NORTH CAMPUS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: compact ? 10 : 12,
                    letterSpacing: compact ? 0.8 : 1.4,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TRUST 54%',
                style: TextStyle(
                  color: const Color(0xFF7CFF41),
                  fontSize: compact ? 10 : 12,
                  letterSpacing: compact ? 0.8 : 1.4,
                ),
              ),
              SizedBox(height: compact ? 4 : 6),
              const _HudBars(active: 3),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissionPanel extends StatelessWidget {
  const _MissionPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 18),
      decoration: _panelDecoration(radius: compact ? 14 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT OBJECTIVE',
            style: TextStyle(
              color: const Color(0xFF7CFF41),
              fontSize: compact ? 11 : 13,
              letterSpacing: compact ? 1.0 : 1.8,
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            'Reach the Engineering Block and verify the signal near Room 207 before the contact disappears again.',
            style: TextStyle(
              color: const Color(0xFFEAFAEA),
              fontSize: compact ? 15 : 22,
              height: 1.3,
            ),
          ),
          SizedBox(height: compact ? 12 : 18),
          _ObjectiveRow(
            compact: compact,
            title: 'Primary clue',
            value: 'Student sent location ping from Engineering Block',
          ),
          SizedBox(height: compact ? 8 : 12),
          _ObjectiveRow(
            compact: compact,
            title: 'Danger',
            value: 'Signal corruption is increasing across campus network',
          ),
          SizedBox(height: compact ? 8 : 12),
          _ObjectiveRow(
            compact: compact,
            title: 'Evidence bag',
            value: '0 photos, 1 chat archive, 0 access cards',
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: compact ? 12 : 16,
            ),
            decoration: _panelDecoration(
              radius: compact ? 12 : 0,
              glow: 0.12,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: const Color(0xFF7CFF41),
                  size: compact ? 24 : 30,
                ),
                SizedBox(width: compact ? 10 : 12),
                Expanded(
                  child: Text(
                    'ENTER ENGINEERING BLOCK',
                    style: TextStyle(
                      color: const Color(0xFFEAFAEA),
                      fontSize: compact ? 14 : 17,
                      letterSpacing: compact ? 0.8 : 1.4,
                    ),
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

class _ObjectiveRow extends StatelessWidget {
  const _ObjectiveRow({
    required this.compact,
    required this.title,
    required this.value,
  });

  final bool compact;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.white70,
            fontSize: compact ? 9 : 11,
            letterSpacing: compact ? 0.8 : 1.4,
          ),
        ),
        SizedBox(height: compact ? 4 : 6),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFFBFFF9A),
            fontSize: compact ? 12 : 14,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.compact,
  });

  final _CampusLocation location;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: _panelDecoration(radius: compact ? 14 : 0),
      child: Row(
        children: [
          Container(
            width: compact ? 46 : 58,
            height: compact ? 46 : 58,
            decoration: _panelDecoration(radius: compact ? 12 : 0, glow: 0.1),
            child: Icon(
              location.icon,
              color: const Color(0xFF7CFF41),
              size: compact ? 22 : 28,
            ),
          ),
          SizedBox(width: compact ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.title,
                  style: TextStyle(
                    color: const Color(0xFFEAFAEA),
                    fontSize: compact ? 14 : 18,
                    letterSpacing: compact ? 0.8 : 1.5,
                  ),
                ),
                SizedBox(height: compact ? 4 : 6),
                Text(
                  location.subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: compact ? 11 : 13,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: compact ? 8 : 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _StatusChip(text: location.status),
                    _StatusChip(text: '${location.clueCount} CLUES'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 8 : 12),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF7CFF41),
            size: compact ? 22 : 28,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF7CFF41).withValues(alpha: 0.34),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF7CFF41),
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 18,
        vertical: compact ? 10 : 14,
      ),
      decoration: _panelDecoration(radius: compact ? 14 : 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'LAST MESSAGE: "DON\'T COME ALONE."',
              style: TextStyle(
                color: const Color(0xFF7CFF41),
                fontSize: compact ? 10 : 12,
                letterSpacing: compact ? 0.8 : 1.4,
              ),
            ),
          ),
          SizedBox(width: compact ? 10 : 16),
          const _HudBars(active: 4),
        ],
      ),
    );
  }
}

class _HudBars extends StatelessWidget {
  const _HudBars({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    const heights = [8.0, 12.0, 16.0, 20.0];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(heights.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Container(
            width: 5,
            height: heights[index],
            color: index < active
                ? const Color(0xFF7CFF41)
                : const Color(0xFF7CFF41).withValues(alpha: 0.18),
          ),
        );
      }),
    );
  }
}

class _IconShell extends StatelessWidget {
  const _IconShell({
    required this.icon,
    required this.compact,
    this.onTap,
  });

  final IconData icon;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 48.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: _panelDecoration(radius: compact ? 12 : 0),
        child: Icon(
          icon,
          color: const Color(0xFF7CFF41),
          size: compact ? 20 : 24,
        ),
      ),
    );
  }
}

class _InvestigationScanlines extends StatelessWidget {
  const _InvestigationScanlines();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _InvestigationScanlinePainter(),
        child: Container(),
      ),
    );
  }
}

class _InvestigationScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF7CFF41).withValues(alpha: 0.025)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

BoxDecoration _panelDecoration({double radius = 0, double glow = 0.07}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: const Color(0xFF7CFF41).withValues(alpha: 0.34),
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF7CFF41).withValues(alpha: glow),
        blurRadius: 16,
      ),
    ],
    color: const Color(0xFF020502).withValues(alpha: 0.82),
  );
}
