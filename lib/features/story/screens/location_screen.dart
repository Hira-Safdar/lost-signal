import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lost_signal/shared/settings/app_settings.dart';

import '../models/player_profile.dart';
import 'campus_map_screen.dart' show StoryLocation;

class LocationScreen extends StatefulWidget {
  const LocationScreen({
    super.key,
    required this.gender,
    required this.location,
    required this.collectedClues,
  });

  final PlayerGender gender;
  final StoryLocation location;
  final Set<String> collectedClues;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late final Set<String> _clues;
  late final AudioPlayer _ambiencePlayer;
  late final AudioPlayer _sfxPlayer;
  AppSettingsController? _settings;
  final Map<String, Offset> _searchOffsets = <String, Offset>{};
  String? _lastFoundClueId;

  static const Map<String, String> _clueLabels = {
    'badge': 'Nathan Kim\'s student ID left beside the Engineering Block desk',
    'notice': 'Missing student report posted outside Room 207',
    'logbook': 'Nathan\'s broken phone containing the last unsent draft',
    'photo': 'Library evidence photo showing Nathan near the admin corridor',
    'security_card': 'Dormitory security card linked to after-hours access',
    'keycard': 'Old basement key tagged from university maintenance',
  };

  static const Map<String, String> _clueDetails = {
    'badge': 'The ID confirms the sender is Nathan Kim, a third-year student. It was dropped in Engineering Block, proving he reached Room 207.',
    'notice': 'The report says Nathan was declared missing the same night. Last seen entering Engineering Block after 2:13 AM.',
    'logbook': 'The broken phone still holds a draft: "If I lose signal, the admin archive key opens the basement service door."',
    'photo': 'A blurred photo from the library archive shows Nathan arguing with someone from the Admin Office before heading toward Engineering.',
    'security_card': 'The dorm security card logs a late-night exit from Nathan\'s floor and a second unauthorized swipe near a restricted campus door.',
    'keycard': 'The old key is tagged for basement maintenance access. It completes the route mentioned in Nathan\'s messages and phone draft.',
  };

  static const Map<String, String> _clueImages = {
    'badge': 'assets/images/student_id.png',
    'notice': 'assets/images/missing_report.png',
    'logbook': 'assets/images/broken_phone.png',
    'photo': 'assets/images/horror_asset.png',
    'security_card': 'assets/images/security_card.png',
    'keycard': 'assets/images/old_key.png',
  };

  static const Map<String, List<_SceneItem>> _sceneItems = {
    'engineering': [
      _SceneItem(
        id: 'desk_papers',
        label: 'Drag desk papers',
        alignment: Alignment(0.74, 0.86),
        size: Size(126, 60),
        direction: Axis.horizontal,
        clueId: 'badge',
      ),
      _SceneItem(
        id: 'notice_board',
        label: 'Slide board notices',
        alignment: Alignment(0.18, 0.08),
        size: Size(90, 74),
        direction: Axis.vertical,
        clueId: 'notice',
      ),
    ],
    'library': [
      _SceneItem(
        id: 'reading_notes',
        label: 'Move desk journal',
        alignment: Alignment(0.78, 0.92),
        size: Size(120, 66),
        direction: Axis.horizontal,
        clueId: 'logbook',
      ),
      _SceneItem(
        id: 'poster_stack',
        label: 'Pull poster corner',
        alignment: Alignment(0.88, -0.08),
        size: Size(82, 92),
        direction: Axis.vertical,
        clueId: 'photo',
      ),
    ],
    'dormitory': [
      _SceneItem(
        id: 'bed_sheet',
        label: 'Drag blanket edge',
        alignment: Alignment(0.52, 0.60),
        size: Size(130, 74),
        direction: Axis.horizontal,
        clueId: 'security_card',
      ),
    ],
    'basement': [
      _SceneItem(
        id: 'crate_lid',
        label: 'Slide crate lid',
        alignment: Alignment(0.84, 0.72),
        size: Size(110, 70),
        direction: Axis.horizontal,
        clueId: 'keycard',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _clues = Set<String>.from(widget.collectedClues);
    _ambiencePlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _startLocationAudio();
    for (final item in _sceneItems[widget.location.id] ?? const <_SceneItem>[]) {
      _searchOffsets[item.id] = Offset.zero;
    }
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

  Future<void> _startLocationAudio() async {
    await _ambiencePlayer.setReleaseMode(ReleaseMode.loop);
    final settings = _settings;
    final ambience = switch (widget.location.id) {
      'basement' => 'sounds/heartbeat.mp3',
      'library' => settings?.whispersEnabled ?? true
          ? 'sounds/creepy_whisper.mp3'
          : 'sounds/industrial_hum.mp3',
      'engineering' => 'sounds/circuit_hum.mp3',
      'dormitory' => 'sounds/phone_interference.mp3',
      _ => 'sounds/industrial_hum.mp3',
    };
    await _ambiencePlayer.play(AssetSource(ambience));
    _applySettings();
  }

  Future<void> _applySettings() async {
    final settings = _settings;
    if (settings == null) {
      return;
    }
    final baseAmbient = widget.location.id == 'basement' ? 0.26 : 0.16;
    await _ambiencePlayer.setVolume((settings.ambientMix * baseAmbient).clamp(0.0, 1.0));
    await _sfxPlayer.setVolume((settings.effectsMix * 0.22).clamp(0.0, 1.0));
  }

  Future<void> _playEffect(String asset, double volume) async {
    await _sfxPlayer.stop();
    await _sfxPlayer.setVolume(((_settings?.effectsMix ?? 1) * volume).clamp(0.0, 1.0));
    await _sfxPlayer.play(AssetSource(asset));
  }

  bool _isItemMoved(_SceneItem item) {
    final offset = _searchOffsets[item.id] ?? Offset.zero;
    return item.direction == Axis.horizontal
        ? offset.dx.abs() > 48
        : offset.dy.abs() > 40;
  }

  Future<void> _collectClue(String clueId) async {
    if (_clues.contains(clueId)) {
      return;
    }
    setState(() {
      _clues.add(clueId);
      _lastFoundClueId = clueId;
    });
    await _playEffect('sounds/live_chat.mp3', 0.22);
  }

  @override
  void dispose() {
    _settings?.removeListener(_applySettings);
    _ambiencePlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _sceneItems[widget.location.id] ?? const <_SceneItem>[];
    final foundCount = _clues.where(widget.location.clueIds.contains).length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(widget.location.imagePath, fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.24)),
          SafeArea(
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
                          onTap: () => Navigator.of(context).pop(_clues),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.location.title,
                                style: const TextStyle(
                                  color: Color(0xFF7CFF41),
                                  fontSize: 17,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Search the room. Move objects to uncover hidden clues.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.76),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$foundCount / ${widget.location.clueIds.length}',
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
                          child: Container(decoration: _panelDecoration(glow: 0.04)),
                        ),
                        ...items.map((item) {
                          final revealed = _isItemMoved(item);
                          final found = _clues.contains(item.clueId);
                          final clueImage = _clueImages[item.clueId]!;
                          return Stack(
                            children: [
                              Align(
                                alignment: item.alignment,
                                child: GestureDetector(
                                  onTap: revealed && !found
                                      ? () => _collectClue(item.clueId)
                                      : null,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 180),
                                    opacity: revealed && !found ? 1 : (found ? 0.22 : 0.0),
                                    child: Container(
                                      width: item.size.width * 0.72,
                                      padding: const EdgeInsets.all(4),
                                      decoration: _panelDecoration(glow: 0.16),
                                      child: Image.asset(clueImage, fit: BoxFit.contain),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: item.alignment,
                                child: Transform.translate(
                                  offset: _searchOffsets[item.id] ?? Offset.zero,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      final current = _searchOffsets[item.id] ?? Offset.zero;
                                      final next = item.direction == Axis.horizontal
                                          ? Offset((current.dx + details.delta.dx).clamp(-70, 70), 0)
                                          : Offset(0, (current.dy + details.delta.dy).clamp(-60, 60));
                                      setState(() {
                                        _searchOffsets[item.id] = next;
                                      });
                                    },
                                    onPanEnd: (_) => _playEffect('sounds/footstep.mp3', 0.12),
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 180),
                                      opacity: found ? 0.28 : 0.94,
                                      child: Container(
                                        width: item.size.width,
                                        height: item.size.height,
                                        decoration: _panelDecoration(glow: 0.10),
                                        padding: const EdgeInsets.all(10),
                                        child: Center(
                                          child: Text(
                                            item.label,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFFEAFAEA),
                                              fontSize: 11,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: _panelDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.gender.subject == 'He' ? 'Nathan' : 'Sara'} is reconstructing Nathan Kim\'s path through ${widget.location.title.toLowerCase()}.',
                                  style: const TextStyle(
                                    color: Color(0xFFEAFAEA),
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...widget.location.clueIds.map((clueId) {
                                  final found = _clues.contains(clueId);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Icon(
                                          found ? Icons.check_circle : Icons.radio_button_unchecked,
                                          color: const Color(0xFF7CFF41),
                                          size: 15,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _clueLabels[clueId]!,
                                            style: TextStyle(
                                              color: found ? const Color(0xFFBFFF9A) : Colors.white70,
                                              fontSize: 12,
                                              height: 1.25,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                if (_lastFoundClueId != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: _panelDecoration(glow: 0.12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'LATEST FIND',
                                          style: TextStyle(
                                            color: Color(0xFF7CFF41),
                                            fontSize: 11,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _clueDetails[_lastFoundClueId]!,
                                          style: const TextStyle(
                                            color: Color(0xFFEAFAEA),
                                            fontSize: 12,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      await _playEffect('sounds/door_open.mp3', 0.18);
                      if (context.mounted) {
                        Navigator.of(context).pop(_clues);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: _panelDecoration(glow: 0.12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.exit_to_app_rounded,
                            color: Color(0xFF7CFF41),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'LEAVE WITH $foundCount / ${widget.location.clueIds.length} CLUES',
                              style: const TextStyle(
                                color: Color(0xFFEAFAEA),
                                fontSize: 15,
                                letterSpacing: 1.0,
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

class _SceneItem {
  const _SceneItem({
    required this.id,
    required this.label,
    required this.alignment,
    required this.size,
    required this.direction,
    required this.clueId,
  });

  final String id;
  final String label;
  final Alignment alignment;
  final Size size;
  final Axis direction;
  final String clueId;
}

BoxDecoration _panelDecoration({double glow = 0.08}) {
  return BoxDecoration(
    border: Border.all(
      color: const Color(0xFF7CFF41).withValues(alpha: 0.34),
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
