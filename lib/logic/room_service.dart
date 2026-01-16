import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crea stanza
  Future<String> createRoom(String name, String gmId) async {
    String code = _generateCode();
    
    await _db.collection('rooms').doc(code).set({
      'code': code,
      'name': name,
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

  // --- FIX: SALVA L'INTERO PERSONAGGIO NELL'ARRAY ---
  Future<bool> joinRoom(String code, Map<String, dynamic> playerData) async {
    final docRef = _db.collection('rooms').doc(code);
    final doc = await docRef.get();
    
    if (!doc.exists) return false;

    // Rimuove eventuali versioni vecchie dello stesso personaggio per aggiornare i dati
    List<dynamic> currentPlayers = doc.data()?['players'] ?? [];
    currentPlayers.removeWhere((p) => p['id'] == playerData['id']);
    
    // Aggiunge timestamp di join
    playerData['joinedAt'] = DateTime.now().toIso8601String();

    // Aggiunge la nuova versione
    currentPlayers.add(playerData);

    await docRef.update({
      'players': currentPlayers
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