import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crea stanza e salva l'ID del GM
  Future<String> createRoom(String name, String gmId) async {
    String code = _generateCode();
    
    // Controlla che il codice non esista (opzionale ma consigliato)
    // ...

    await _db.collection('rooms').doc(code).set({
      'code': code,
      'name': name,
      'gmId': gmId, // <--- COLLEGA LA STANZA AL GM
      'createdAt': FieldValue.serverTimestamp(),
      'combat_active': false,
      'turn_index': 0,
      'combatants': [],
      'players': []
    });

    return code;
  }

  // Recupera tutte le stanze create da questo GM
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

  // ... (metodo joinRoom e _generateCode esistenti rimangono uguali)
  Future<bool> joinRoom(String code, String charId, String charName) async {
    final docRef = _db.collection('rooms').doc(code);
    final doc = await docRef.get();
    
    if (!doc.exists) return false;

    // Aggiungi player alla lista se non c'è
    List players = doc.data()?['players'] ?? [];
    if (!players.any((p) => p['id'] == charId)) {
      await docRef.update({
        'players': FieldValue.arrayUnion([{
          'id': charId, 
          'name': charName,
          'joinedAt': DateTime.now().toIso8601String()
        }])
      });
    }
    return true;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}