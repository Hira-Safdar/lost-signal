import 'package:flutter/material.dart';
import 'package:lost_signal/shared/settings/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
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
                  _SettingsHeader(onBack: () => Navigator.of(context).pop()),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      children: [
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildAudioCard(settings)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildVisualsCard(settings),
                                    const SizedBox(height: 14),
                                    _buildGameplayCard(settings),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildAudioCard(settings),
                          const SizedBox(height: 14),
                          _buildVisualsCard(settings),
                          const SizedBox(height: 14),
                          _buildGameplayCard(settings),
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

  Widget _buildAudioCard(AppSettingsController settings) {
    return _SectionCard(
      title: 'AUDIO',
      child: Column(
        children: [
          _SliderRow(
            label: 'Master Volume',
            value: settings.masterVolume * 100,
            onChanged: (value) => settings.setMasterVolume(value / 100),
          ),
          const SizedBox(height: 12),
          _SliderRow(
            label: 'Ambient Hum',
            value: settings.ambientVolume * 100,
            onChanged: (value) => settings.setAmbientVolume(value / 100),
          ),
          const SizedBox(height: 12),
          _SliderRow(
            label: 'Effects Volume',
            value: settings.effectsVolume * 100,
            onChanged: (value) => settings.setEffectsVolume(value / 100),
          ),
          const SizedBox(height: 14),
          _ToggleRow(
            title: 'Creepy Whispers',
            subtitle: 'Enable low whisper ambience in dark locations',
            value: settings.whispersEnabled,
            onChanged: settings.setWhispersEnabled,
          ),
          const SizedBox(height: 10),
          _ToggleRow(
            title: 'Vibration',
            subtitle: 'Use subtle haptics for glitch and clue events',
            value: settings.vibrationEnabled,
            onChanged: settings.setVibrationEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildVisualsCard(AppSettingsController settings) {
    return _SectionCard(
      title: 'VISUALS',
      child: Column(
        children: [
          _ToggleRow(
            title: 'CRT Scanlines',
            subtitle: 'Keep the infected monitor look active',
            value: settings.scanlinesEnabled,
            onChanged: settings.setScanlinesEnabled,
          ),
          const SizedBox(height: 10),
          _ToggleRow(
            title: 'Glitch Effects',
            subtitle: 'Enable flickers, interference and corruption overlays',
            value: settings.glitchEffectsEnabled,
            onChanged: settings.setGlitchEffectsEnabled,
          ),
          const SizedBox(height: 10),
          _ToggleRow(
            title: 'Subtitles / Clue Text',
            subtitle: 'Always show readable text for story and evidence',
            value: settings.subtitlesEnabled,
            onChanged: settings.setSubtitlesEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildGameplayCard(AppSettingsController settings) {
    return _SectionCard(
      title: 'GAMEPLAY',
      child: Column(
        children: [
          _SelectRow(
            title: 'Text Speed',
            value: settings.textSpeed,
            options: const ['Slow', 'Normal', 'Fast'],
            onSelected: settings.setTextSpeed,
          ),
          const SizedBox(height: 12),
          _SelectRow(
            title: 'Difficulty Style',
            value: settings.difficulty,
            options: const ['Story', 'Tense', 'Hardcore'],
            onSelected: settings.setDifficulty,
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onBack});

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
                  'SETTINGS',
                  style: TextStyle(
                    color: Color(0xFF7CFF41),
                    fontSize: 18,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Adjust sound, visuals and story experience.',
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Color(0xFFEAFAEA), fontSize: 15),
              ),
            ),
            Text(
              '${value.round()}%',
              style: const TextStyle(color: Color(0xFF7CFF41), fontSize: 13),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF7CFF41),
            inactiveTrackColor: Colors.white12,
            thumbColor: const Color(0xFFBFFF9A),
            overlayColor: const Color(0x337CFF41),
          ),
          child: Slider(value: value, min: 0, max: 100, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFFEAFAEA), fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          activeThumbColor: const Color(0xFF7CFF41),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SelectRow extends StatelessWidget {
  const _SelectRow({
    required this.title,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFFEAFAEA), fontSize: 15),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final selected = option == value;
            return GestureDetector(
              onTap: () => onSelected(option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: _panelDecoration(
                  selected: selected,
                  glow: selected ? 0.14 : 0.04,
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFBFFF9A)
                        : const Color(0xFFEAFAEA),
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

BoxDecoration _panelDecoration({double glow = 0.08, bool selected = false}) {
  return BoxDecoration(
    border: Border.all(
      color: const Color(0xFF7CFF41).withValues(alpha: selected ? 0.74 : 0.34),
      width: selected ? 1.4 : 1,
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
