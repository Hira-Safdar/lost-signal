import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../../features/chat/models/chat_message.dart';
import '../../features/story/models/player_profile.dart';
import 'game_repository.dart';
import 'game_save.dart';

class GameController extends ChangeNotifier {
  GameController(this._auth, this._repository);

  final FirebaseAuth _auth;
  final GameRepository _repository;

  GameSave _save = GameSave.empty();
  bool _isReady = false;
  bool _isBusy = false;
  String? _uid;

  bool get isReady => _isReady;
  bool get isBusy => _isBusy;
  String? get uid => _uid;
  GameSave get save => _save;
  bool get hasActiveSave => _save.storyPhase != 'not_started';
  bool get canContinue => hasActiveSave && _save.endingId == null;
  bool get hasEnding => _save.endingId != null;
  PlayerGender? get selectedGender {
    return switch (_save.characterId) {
      'male' => PlayerGender.male,
      'female' => PlayerGender.female,
      _ => null,
    };
  }

  Future<void> initialize() async {
    if (_isReady || _isBusy) {
      return;
    }
    _isBusy = true;
    notifyListeners();
    try {
      final currentUser = _auth.currentUser ?? (await _auth.signInAnonymously()).user;
      _uid = currentUser?.uid;
      if (_uid != null) {
        _save = await _repository.loadSave(_uid!) ?? GameSave.empty();
      }
      _isReady = true;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    if (_uid == null) {
      return;
    }
    await _repository.saveGame(_uid!, _save);
    notifyListeners();
  }

  Future<void> startNewGame() async {
    _save = GameSave.empty().copyWith(
      currentScreenId: 'character_select',
    );
    await _persist();
  }

  Future<void> setCharacter(PlayerGender gender) async {
    _save = _save.copyWith(
      characterId: gender == PlayerGender.male ? 'male' : 'female',
      currentScreenId: 'chapter_intro',
      storyPhase: 'intro',
    );
    await _persist();
  }

  Future<void> openChat() async {
    _save = _save.copyWith(
      currentScreenId: 'chat',
      storyPhase: _save.storyPhase == 'intro' ? 'chat_dorm' : _save.storyPhase,
      currentObjectiveId: 'contact_nathan',
      currentChatNodeId: _save.currentChatNodeId.isEmpty ? 'entry' : _save.currentChatNodeId,
    );
    await _persist();
  }

  Future<void> saveChatState({
    required String currentNodeId,
    required String storyPhase,
    required String lastPingLocationId,
    required int signalStrength,
    required int trustScore,
    required List<ChatMessage> messages,
  }) async {
    _save = _save.copyWith(
      currentScreenId: 'chat',
      currentChatNodeId: currentNodeId,
      storyPhase: storyPhase,
      lastPingLocationId: lastPingLocationId,
      signalStrength: signalStrength,
      trustScore: trustScore,
      messageLog: messages
          .map(
            (message) => <String, dynamic>{
              'sender': message.sender.name,
              'text': message.text,
              'timestamp': message.timestamp,
              'isCorrupted': message.isCorrupted,
            },
          )
          .toList(growable: false),
    );
    await _persist();
  }

  Future<void> openMap({
    required String storyPhase,
    required String objectiveId,
    required String lastPingLocationId,
    List<String>? unlockedLocationIds,
  }) async {
    _save = _save.copyWith(
      currentScreenId: 'campus_map',
      storyPhase: storyPhase,
      currentObjectiveId: objectiveId,
      lastPingLocationId: lastPingLocationId,
      unlockedLocationIds: unlockedLocationIds ?? _save.unlockedLocationIds,
    );
    await _persist();
  }

  Future<void> updateLocationProgress({
    required String locationId,
    required List<String> collectedClues,
    required List<String> completedLocationIds,
    required List<String> unlockedLocationIds,
    required String objectiveId,
    required String storyPhase,
  }) async {
    _save = _save.copyWith(
      currentScreenId: 'campus_map',
      collectedClueIds: collectedClues,
      completedLocationIds: completedLocationIds,
      unlockedLocationIds: unlockedLocationIds,
      currentObjectiveId: objectiveId,
      storyPhase: storyPhase,
      lastPingLocationId: locationId,
    );
    await _persist();
  }

  Future<void> openCaseFile() async {
    _save = _save.copyWith(currentScreenId: 'case_file');
    await _persist();
  }

  Future<void> closeCaseFile() async {
    _save = _save.copyWith(currentScreenId: 'campus_map');
    await _persist();
  }

  Future<void> completeChapter({
    required String endingId,
    required String storyPhase,
  }) async {
    _save = _save.copyWith(
      currentScreenId: 'ending',
      endingId: endingId,
      storyPhase: storyPhase,
    );
    await _persist();
  }

  Future<void> replayChapter() async {
    await startNewGame();
  }

  String nextObjectiveLabel() {
    return switch (_save.currentObjectiveId) {
      'recover_engineering' => 'Recover Nathan\'s ID and the poster clue in Engineering.',
      'verify_admin' => 'Verify the report trail in Admin Office.',
      'recover_library' => 'Recover the broken phone and archive photo in Library.',
      'recover_dormitory' => 'Recover the dormitory security card.',
      'confirm_basement' => 'Confirm the basement route and finish the chapter.',
      _ => 'Answer Nathan and rebuild his route.',
    };
  }
}

class GameScope extends InheritedNotifier<GameController> {
  const GameScope({
    super.key,
    required GameController controller,
    required super.child,
  }) : super(notifier: controller);

  static GameController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GameScope>();
    assert(scope != null, 'GameScope is missing in the widget tree.');
    return scope!.notifier!;
  }

  static GameController read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<GameScope>();
    final scope = element?.widget as GameScope?;
    assert(scope != null, 'GameScope is missing in the widget tree.');
    return scope!.notifier!;
  }
}
