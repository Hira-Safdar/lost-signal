import 'package:flutter/widgets.dart';

class AppSettingsController extends ChangeNotifier {
  double _masterVolume = 0.72;
  double _ambientVolume = 0.58;
  double _effectsVolume = 0.80;
  bool _scanlinesEnabled = true;
  bool _glitchEffectsEnabled = true;
  bool _whispersEnabled = true;
  bool _vibrationEnabled = false;
  bool _subtitlesEnabled = true;
  String _textSpeed = 'Normal';
  String _difficulty = 'Story';

  double get masterVolume => _masterVolume;
  double get ambientVolume => _ambientVolume;
  double get effectsVolume => _effectsVolume;
  bool get scanlinesEnabled => _scanlinesEnabled;
  bool get glitchEffectsEnabled => _glitchEffectsEnabled;
  bool get whispersEnabled => _whispersEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get subtitlesEnabled => _subtitlesEnabled;
  String get textSpeed => _textSpeed;
  String get difficulty => _difficulty;

  double get ambientMix => _masterVolume * _ambientVolume;
  double get effectsMix => _masterVolume * _effectsVolume;

  void setMasterVolume(double value) {
    _masterVolume = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setAmbientVolume(double value) {
    _ambientVolume = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setEffectsVolume(double value) {
    _effectsVolume = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setScanlinesEnabled(bool value) {
    _scanlinesEnabled = value;
    notifyListeners();
  }

  void setGlitchEffectsEnabled(bool value) {
    _glitchEffectsEnabled = value;
    notifyListeners();
  }

  void setWhispersEnabled(bool value) {
    _whispersEnabled = value;
    notifyListeners();
  }

  void setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    notifyListeners();
  }

  void setSubtitlesEnabled(bool value) {
    _subtitlesEnabled = value;
    notifyListeners();
  }

  void setTextSpeed(String value) {
    _textSpeed = value;
    notifyListeners();
  }

  void setDifficulty(String value) {
    _difficulty = value;
    notifyListeners();
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope is missing in the widget tree.');
    return scope!.notifier!;
  }

  static AppSettingsController read(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<AppSettingsScope>();
    final scope = element?.widget as AppSettingsScope?;
    assert(scope != null, 'AppSettingsScope is missing in the widget tree.');
    return scope!.notifier!;
  }
}
