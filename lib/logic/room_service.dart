import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crea stanza
  Future<String> createRoom(String name, String gmId) async {
    String code = _generateCode();
    
    await _db.collection('rooms').doc(code).set({
      'code': code,
      'roomName': name, // Uniformato a roomName
      'gmId': gmId,
      'createdAt': FieldValue.serverTimestamp(),
      'combat_active': false,
      'turn_index': 0,
      'combatants': [],
      'players': []
    });

    return code;
  }

  // Recupera stanze GM
  Future<List<Map<String, dynamic>>> getRoomsForGm(String gmId) async {
    try {
      final snapshot = await _db.collection('rooms')
          .where('gmId', isEqualTo: gmId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Errore getRoomsForGm: $e");
      return [];
    }
  }

  // --- FIX: SANITIZZAZIONE DATI PERSONAGGIO ---
  Future<bool> joinRoom(String code, Map<String, dynamic> rawPlayerData) async {
    final docRef = _db.collection('rooms').doc(code);
    final doc = await docRef.get();
    
    if (!doc.exists) return false;

    // Creiamo una copia sicura dei dati
    final Map<String, dynamic> safeData = Map.from(rawPlayerData);
    
    // Assicuriamo che i campi lista non siano null
    safeData['inventory'] = safeData['inventory'] ?? [];
    safeData['activeCards'] = safeData['activeCards'] ?? [];
    safeData['weapons'] = safeData['weapons'] ?? [];
    safeData['armor'] = safeData['armor'] ?? [];
    
    // Aggiungiamo timestamp di join
    safeData['joinedAt'] = DateTime.now().toIso8601String();

    // Gestione concorrenza: rimuovi vecchio, aggiungi nuovo
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      List<dynamic> currentPlayers = List.from(snapshot.data()?['players'] ?? []);
      currentPlayers.removeWhere((p) => p['id'] == safeData['id']);
      currentPlayers.add(safeData);

      transaction.update(docRef, {'players': currentPlayers});
    });
    
    return true;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}