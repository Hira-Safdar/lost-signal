import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lost_signal/features/story/screens/case_file_screen.dart';
import 'package:lost_signal/shared/game/game_controller.dart';
import 'package:lost_signal/shared/settings/app_settings.dart';

import '../models/player_profile.dart';
import 'ending_screen.dart';
import 'location_screen.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({
    super.key,
    required this.gender,
    required this.signalStrength,
    required this.trustScore,
  });

  final PlayerGender gender;
  final int signalStrength;
  final int trustScore;

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  static const List<StoryLocation> _locations = [
    StoryLocation(
      id: 'library',
      title: 'LIBRARY',
      subtitle: 'Archive evidence connecting Nathan to the admin corridor.',
      clueIds: ['logbook', 'photo'],
      imagePath: 'assets/images/library.png',
      icon: Icons.local_library_outlined,
      markerAlignment: Alignment(-0.56, -0.37),
      markerColor: Color(0xFF3DDCFF),
    ),
    StoryLocation(
      id: 'engineering',
      title: 'ENGINEERING BLOCK',
      subtitle: 'Room 207, the missing report, and Nathan\'s dropped ID.',
      clueIds: ['badge', 'notice'],
      imagePath: 'assets/images/engineering_block.png',
      icon: Icons.apartment_rounded,
      markerAlignment: Alignment(0.50, -0.18),
      markerColor: Color(0xFFFFC247),
    ),
    StoryLocation(
      id: 'dormitory',
      title: 'DORMITORY',
      subtitle: 'Nathan\'s last confirmed room and access history.',
      clueIds: ['security_card'],
      imagePath: 'assets/images/dormitory.png',
      icon: Icons.night_shelter_outlined,
      markerAlignment: Alignment(-0.53, 0.36),
      markerColor: Color(0xFF4CFF76),
    ),
    StoryLocation(
      id: 'admin',
      title: 'ADMIN OFFICE',
      subtitle: 'Official records behind Nathan\'s disappearance.',
      clueIds: ['archive_route'],
      imagePath: 'assets/images/admin.png',
      icon: Icons.domain_outlined,
      markerAlignment: Alignment(0.10, -0.72),
      markerColor: Color(0xFFFF5B7A),
    ),
    StoryLocation(
      id: 'basement',
      title: 'BASEMENT ENTRANCE',
      subtitle:
          'The final route mentioned in Nathan\'s draft and report trail.',
      clueIds: ['keycard'],
      imagePath: 'assets/images/basement.png',
      icon: Icons.stairs_outlined,
      markerAlignment: Alignment(0.52, 0.52),
      markerColor: Color(0xFFFF4C4C),
    ),
  ];

  final Set<String> _collectedClues = <String>{};
  final Set<String> _completedLocations = <String>{};
  final Set<String> _unlockedLocations = <String>{};
  late final AudioPlayer _humPlayer;
  late final AudioPlayer _sfxPlayer;
  AppSettingsController? _settings;
  GameController? _game;

  int get _clueCount => _collectedClues.length;
  bool get _chapterReadyForEnding => _completedLocations.containsAll(
    const <String>['engineering', 'admin', 'library', 'dormitory', 'basement'],
  );

  @override
  void initState() {
    super.initState();
    _humPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _startAmbient();
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
    final nextGame = GameScope.of(context);
    if (!identical(_game, nextGame)) {
      _game = nextGame;
      _hydrateFromSave(nextGame);
    }
  }

  void _hydrateFromSave(GameController game) {
    _collectedClues
      ..clear()
      ..addAll(game.save.collectedClueIds);
    _completedLocations
      ..clear()
      ..addAll(game.save.completedLocationIds);
    _unlockedLocations
      ..clear()
      ..addAll(
        game.save.unlockedLocationIds.isEmpty
            ? const <String>['engineering']
            : game.save.unlockedLocationIds,
      );
  }

  Future<void> _startAmbient() async {
    await _humPlayer.setReleaseMode(ReleaseMode.loop);
    await _humPlayer.play(AssetSource('sounds/industrial_hum.mp3'));
    _applySettings();
  }

  Future<void> _applySettings() async {
    final settings = _settings;
    if (settings == null) {
      return;
    }
    await _humPlayer.setVolume((settings.ambientMix * 0.20).clamp(0.0, 1.0));
    await _sfxPlayer.setVolume((settings.effectsMix * 0.20).clamp(0.0, 1.0));
  }

  Future<void> _playMapTap() async {
    await _sfxPlayer.stop();
    await _applySettings();
    await _sfxPlayer.play(AssetSource('sounds/footstep.mp3'));
  }

  @override
  void dispose() {
    _settings?.removeListener(_applySettings);
    _humPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  Future<void> _openLocation(StoryLocation location) async {
    if (!_unlockedLocations.contains(location.id)) {
      return;
    }
    unawaited(_playMapTap());
    final result = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute<Set<String>>(
        builder: (_) => LocationScreen(
          gender: widget.gender,
          location: location,
          collectedClues: _collectedClues,
        ),
      ),
    );

    if (result != null) {
      final progress = _deriveProgress(result);
      setState(() {
        _collectedClues
          ..clear()
          ..addAll(result);
        _completedLocations
          ..clear()
          ..addAll(progress.completedLocations);
        _unlockedLocations
          ..clear()
          ..addAll(progress.unlockedLocations);
      });
      await _game?.updateLocationProgress(
        locationId: location.id,
        collectedClues: result.toList(growable: false),
        completedLocationIds: progress.completedLocations.toList(
          growable: false,
        ),
        unlockedLocationIds: progress.unlockedLocations.toList(growable: false),
        objectiveId: progress.objectiveId,
        storyPhase: progress.storyPhase,
      );
    }
  }

  Future<void> _openEnding() async {
    final endingId =
        (widget.signalStrength >= 55 &&
            widget.trustScore >= 55 &&
            _chapterReadyForEnding)
        ? 'signal_held'
        : 'too_late';
    await _game?.completeChapter(
      endingId: endingId,
      storyPhase: 'chapter_complete',
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EndingScreen(
          gender: widget.gender,
          signalStrength: widget.signalStrength,
          trustScore: widget.trustScore,
          clueCount: _clueCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context);
    final effectiveSignal = (widget.signalStrength - (5 - _clueCount) * 4)
        .clamp(24, 99);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/campus_map.png', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.12)),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: _panelDecoration(),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: _panelDecoration(),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Color(0xFF7CFF41),
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CAMPUS MAP',
                                    style: TextStyle(
                                      color: Color(0xFF7CFF41),
                                      fontSize: 17,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Tap a marked building to roam and collect clues.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Signal $effectiveSignal%',
                              style: const TextStyle(
                                color: Color(0xFF7CFF41),
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: _panelDecoration(glow: 0.04),
                              ),
                            ),
                            ..._locations.map((location) {
                              final found = location.clueIds
                                  .where(_collectedClues.contains)
                                  .length;
                              return Align(
                                alignment: location.markerAlignment,
                                child: _MapMarker(
                                  location: location,
                                  found: found,
                                  unlocked: _unlockedLocations.contains(
                                    location.id,
                                  ),
                                  completed: _completedLocations.contains(
                                    location.id,
                                  ),
                                  onTap: () => _openLocation(location),
                                ),
                              );
                            }),
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: _panelDecoration(),
                                          child: Text(
                                            game.nextObjectiveLabel(),
                                            style: const TextStyle(
                                              color: Color(0xFFBFFF9A),
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _InventoryPanel(
                                          collectedClues: _collectedClues,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      await game.openCaseFile();
                                      if (!context.mounted) {
                                        return;
                                      }
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const CaseFileScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 14,
                                      ),
                                      decoration: _panelDecoration(glow: 0.10),
                                      child: const Icon(
                                        Icons.folder_open_rounded,
                                        color: Color(0xFF7CFF41),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: _chapterReadyForEnding
                                        ? _openEnding
                                        : null,
                                    child: Opacity(
                                      opacity: _chapterReadyForEnding
                                          ? 1
                                          : 0.45,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 14,
                                        ),
                                        decoration: _panelDecoration(
                                          glow: 0.14,
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Color(0xFF7CFF41),
                                          size: 28,
                                        ),
                                      ),
                                    ),
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
            ),
          ),
        ],
      ),
    );
  }

  _MapProgress _deriveProgress(Set<String> clues) {
    final completed = <String>{};
    for (final location in _locations) {
      if (location.clueIds.isNotEmpty &&
          location.clueIds.every(clues.contains)) {
        completed.add(location.id);
      }
    }

    final unlocked = <String>{'engineering'};
    if (completed.contains('engineering')) {
      unlocked.add('admin');
    }
    if (completed.contains('admin')) {
      unlocked.addAll(const <String>['library', 'dormitory']);
    }
    if (completed.contains('library') && completed.contains('dormitory')) {
      unlocked.add('basement');
    }

    if (!completed.contains('engineering')) {
      return _MapProgress(
        completedLocations: completed,
        unlockedLocations: unlocked,
        objectiveId: 'recover_engineering',
        storyPhase: 'engineering_phase',
      );
    }
    if (!completed.contains('admin')) {
      return _MapProgress(
        completedLocations: completed,
        unlockedLocations: unlocked,
        objectiveId: 'verify_admin',
        storyPhase: 'admin_phase',
      );
    }
    if (!completed.contains('library')) {
      return _MapProgress(
        completedLocations: completed,
        unlockedLocations: unlocked,
        objectiveId: 'recover_library',
        storyPhase: 'library_phase',
      );
    }
    if (!completed.contains('dormitory')) {
      return _MapProgress(
        completedLocations: completed,
        unlockedLocations: unlocked,
        objectiveId: 'recover_dormitory',
        storyPhase: 'dormitory_phase',
      );
    }
    return _MapProgress(
      completedLocations: completed,
      unlockedLocations: unlocked,
      objectiveId: 'confirm_basement',
      storyPhase: 'basement_phase',
    );
  }
}

class _MapProgress {
  const _MapProgress({
    required this.completedLocations,
    required this.unlockedLocations,
    required this.objectiveId,
    required this.storyPhase,
  });

  final Set<String> completedLocations;
  final Set<String> unlockedLocations;
  final String objectiveId;
  final String storyPhase;
}

class StoryLocation {
  const StoryLocation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.clueIds,
    required this.imagePath,
    required this.icon,
    required this.markerAlignment,
    required this.markerColor,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<String> clueIds;
  final String imagePath;
  final IconData icon;
  final Alignment markerAlignment;
  final Color markerColor;
}

class _MapMarker extends StatefulWidget {
  const _MapMarker({
    required this.location,
    required this.found,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });

  final StoryLocation location;
  final int found;
  final bool unlocked;
  final bool completed;
  final VoidCallback onTap;

  @override
  State<_MapMarker> createState() => _MapMarkerState();
}

class _MapMarkerState extends State<_MapMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final scale = 0.92 + (_controller.value * 0.16);
        final glow = 0.10 + (_controller.value * 0.10);

        return GestureDetector(
          onTap: widget.unlocked ? widget.onTap : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: scale,
                child: Icon(
                  widget.completed
                      ? Icons.verified_rounded
                      : (widget.unlocked
                            ? Icons.location_on_rounded
                            : Icons.lock_outline_rounded),
                  color: widget.unlocked
                      ? widget.location.markerColor
                      : Colors.white54,
                  size: 32,
                  shadows: [
                    Shadow(
                      color:
                          (widget.unlocked
                                  ? widget.location.markerColor
                                  : Colors.white54)
                              .withValues(alpha: 0.55),
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: _panelDecoration(glow: glow),
                child: Column(
                  children: [
                    Text(
                      widget.location.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFEAFAEA),
                        fontSize: 11,
                        letterSpacing: 0.9,
                      ),
                    ),
                    if (widget.location.clueIds.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.completed
                            ? 'COMPLETE'
                            : (widget.unlocked
                                  ? '${widget.found} / ${widget.location.clueIds.length} clues'
                                  : 'LOCKED'),
                        style: const TextStyle(
                          color: Color(0xFF7CFF41),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InventoryPanel extends StatelessWidget {
  const _InventoryPanel({required this.collectedClues});

  final Set<String> collectedClues;

  static const Map<String, String> _labels = {
    'badge': 'Nathan Kim Student ID',
    'notice': 'Room 207 Missing Report',
    'logbook': 'Broken Phone Draft',
    'photo': 'Archive Evidence Photo',
    'security_card': 'Dorm Security Card',
    'keycard': 'Basement Maintenance Key',
  };

  @override
  Widget build(BuildContext context) {
    final items = collectedClues.map((id) => _labels[id] ?? id).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INVENTORY',
            style: TextStyle(
              color: Color(0xFF7CFF41),
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(
              'No clues collected yet.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 11,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '- $item',
                  style: const TextStyle(
                    color: Color(0xFFBFFF9A),
                    fontSize: 11,
                    height: 1.2,
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
