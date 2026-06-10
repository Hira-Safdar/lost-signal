import 'package:cloud_firestore/cloud_firestore.dart';

class GameSave {
  const GameSave({
    required this.characterId,
    required this.chapterId,
    required this.currentScreenId,
    required this.storyPhase,
    required this.currentChatNodeId,
    required this.signalStrength,
    required this.trustScore,
    required this.collectedClueIds,
    required this.unlockedLocationIds,
    required this.completedLocationIds,
    required this.lastPingLocationId,
    required this.currentObjectiveId,
    required this.endingId,
    required this.updatedAt,
    required this.messageLog,
  });

  final String? characterId;
  final String chapterId;
  final String currentScreenId;
  final String storyPhase;
  final String currentChatNodeId;
  final int signalStrength;
  final int trustScore;
  final List<String> collectedClueIds;
  final List<String> unlockedLocationIds;
  final List<String> completedLocationIds;
  final String lastPingLocationId;
  final String currentObjectiveId;
  final String? endingId;
  final DateTime? updatedAt;
  final List<Map<String, dynamic>> messageLog;

  factory GameSave.empty() {
    return const GameSave(
      characterId: null,
      chapterId: 'chapter_1',
      currentScreenId: 'main_menu',
      storyPhase: 'not_started',
      currentChatNodeId: 'entry',
      signalStrength: 87,
      trustScore: 58,
      collectedClueIds: <String>[],
      unlockedLocationIds: <String>[],
      completedLocationIds: <String>[],
      lastPingLocationId: 'dormitory',
      currentObjectiveId: 'start_contact',
      endingId: null,
      updatedAt: null,
      messageLog: <Map<String, dynamic>>[],
    );
  }

  factory GameSave.fromMap(Map<String, dynamic> map) {
    final timestamp = map['updatedAt'];
    return GameSave(
      characterId: map['characterId'] as String?,
      chapterId: map['chapterId'] as String? ?? 'chapter_1',
      currentScreenId: map['currentScreenId'] as String? ?? 'main_menu',
      storyPhase: map['storyPhase'] as String? ?? 'not_started',
      currentChatNodeId: map['currentChatNodeId'] as String? ?? 'entry',
      signalStrength: (map['signalStrength'] as num?)?.toInt() ?? 87,
      trustScore: (map['trustScore'] as num?)?.toInt() ?? 58,
      collectedClueIds: List<String>.from(
        (map['collectedClueIds'] as List<dynamic>? ?? const <dynamic>[]),
      ),
      unlockedLocationIds: List<String>.from(
        (map['unlockedLocationIds'] as List<dynamic>? ?? const <dynamic>[]),
      ),
      completedLocationIds: List<String>.from(
        (map['completedLocationIds'] as List<dynamic>? ?? const <dynamic>[]),
      ),
      lastPingLocationId: map['lastPingLocationId'] as String? ?? 'dormitory',
      currentObjectiveId:
          map['currentObjectiveId'] as String? ?? 'start_contact',
      endingId: map['endingId'] as String?,
      updatedAt: timestamp is Timestamp ? timestamp.toDate() : null,
      messageLog: List<Map<String, dynamic>>.from(
        (map['messageLog'] as List<dynamic>? ?? const <dynamic>[])
            .map((entry) => Map<String, dynamic>.from(entry as Map)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'characterId': characterId,
      'chapterId': chapterId,
      'currentScreenId': currentScreenId,
      'storyPhase': storyPhase,
      'currentChatNodeId': currentChatNodeId,
      'signalStrength': signalStrength,
      'trustScore': trustScore,
      'collectedClueIds': collectedClueIds,
      'unlockedLocationIds': unlockedLocationIds,
      'completedLocationIds': completedLocationIds,
      'lastPingLocationId': lastPingLocationId,
      'currentObjectiveId': currentObjectiveId,
      'endingId': endingId,
      'updatedAt': FieldValue.serverTimestamp(),
      'messageLog': messageLog,
    };
  }

  GameSave copyWith({
    String? characterId,
    String? chapterId,
    String? currentScreenId,
    String? storyPhase,
    String? currentChatNodeId,
    int? signalStrength,
    int? trustScore,
    List<String>? collectedClueIds,
    List<String>? unlockedLocationIds,
    List<String>? completedLocationIds,
    String? lastPingLocationId,
    String? currentObjectiveId,
    Object? endingId = _sentinel,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? messageLog,
  }) {
    return GameSave(
      characterId: characterId ?? this.characterId,
      chapterId: chapterId ?? this.chapterId,
      currentScreenId: currentScreenId ?? this.currentScreenId,
      storyPhase: storyPhase ?? this.storyPhase,
      currentChatNodeId: currentChatNodeId ?? this.currentChatNodeId,
      signalStrength: signalStrength ?? this.signalStrength,
      trustScore: trustScore ?? this.trustScore,
      collectedClueIds: collectedClueIds ?? this.collectedClueIds,
      unlockedLocationIds: unlockedLocationIds ?? this.unlockedLocationIds,
      completedLocationIds: completedLocationIds ?? this.completedLocationIds,
      lastPingLocationId: lastPingLocationId ?? this.lastPingLocationId,
      currentObjectiveId: currentObjectiveId ?? this.currentObjectiveId,
      endingId: identical(endingId, _sentinel) ? this.endingId : endingId as String?,
      updatedAt: updatedAt ?? this.updatedAt,
      messageLog: messageLog ?? this.messageLog,
    );
  }
}

const Object _sentinel = Object();
