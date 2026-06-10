import 'package:cloud_firestore/cloud_firestore.dart';

import 'game_save.dart';

class GameRepository {
  GameRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _saveRef(String uid) {
    return _firestore.collection('player_saves').doc(uid);
  }

  Future<GameSave?> loadSave(String uid) async {
    final snapshot = await _saveRef(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return GameSave.fromMap(snapshot.data()!);
  }

  Future<void> saveGame(String uid, GameSave save) {
    return _saveRef(uid).set(save.toMap(), SetOptions(merge: true));
  }
}
