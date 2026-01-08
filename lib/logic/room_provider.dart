import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../data/models/character.dart';
import '../data/models/adversary.dart';

class RoomProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Stato Sessione
  String? currentRoomCode;
  bool isGm = false;
  String? myUserId;      // ID univoco del dispositivo (usato per Cloud Save e GM)
  String? myCharacterId; // ID del personaggio corrente (se Giocatore)

  // Dati della stanza (Sincronizzati in tempo reale)
  int fear = 0;
  int actionTokens = 0;
  List<dynamic> activeCombatantsData = []; // Lista mista JSON di Nemici e PG
  
  // Stream per la lista giocatori (Solo per GM)
  Stream<QuerySnapshot>? playersStream;

  // --- INIZIALIZZAZIONE (RECUPERO SESSIONE) ---
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Identità del Dispositivo (genera se non esiste)
    if (!prefs.containsKey('user_device_id')) {
      String newId = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();
      await prefs.setString('user_device_id', newId);
    }
    myUserId = prefs.getString('user_device_id');

    // 2. Controllo Sessione Interrotta (Refresh pagina)
    final savedRoom = prefs.getString('room_code');
    final savedIsGm = prefs.getBool('is_gm') ?? false;
    final savedCharId = prefs.getString('char_id');

    if (savedRoom != null) {
      try {
        DocumentSnapshot snap = await _db.collection('rooms').doc(savedRoom).get();
        if (snap.exists) {
          // Riconnessione riuscita
          currentRoomCode = savedRoom;
          isGm = savedIsGm;
          myCharacterId = savedCharId;
          
          _listenToRoom(savedRoom);
          if (isGm) {
            _listenToPlayers(savedRoom);
          }
          notifyListeners();
        } else {
          // La stanza non esiste più online -> Logout
          await exitRoom();
        }
      } catch (e) {
        print("Errore riconnessione: $e");
        await exitRoom();
      }
    }
    // Notifichiamo comunque per aggiornare UI che dipendono da myUserId
    notifyListeners();
  }

  // --- RECUPERO ACCOUNT (NUOVO METODO) ---
  // Permette di forzare un ID utente specifico (es. recuperato da un altro dispositivo)
  Future<void> forceUserId(String newId) async {
    final prefs = await SharedPreferences.getInstance();
    myUserId = newId;
    await prefs.setString('user_device_id', newId);
    notifyListeners();
  }

  // --- GM: GESTIONE STANZE ---
  
  // Ottieni le stanze create da questo GM in passato
  Stream<QuerySnapshot> getMyRooms() {
    if (myUserId == null) return const Stream.empty();
    return _db.collection('rooms')
      .where('gmId', isEqualTo: myUserId)
      .orderBy('createdAt', descending: true)
      .snapshots();
  }

  // Crea una nuova stanza
  Future<String> createRoom(String gmName, String roomName) async {
    String code = DateTime.now().millisecondsSinceEpoch.toString().substring(7, 13);
    
    await _db.collection('rooms').doc(code).set({
      'roomName': roomName,
      'gmName': gmName,
      'gmId': myUserId, // Salviamo l'ID per associare la stanza al GM
      'createdAt': FieldValue.serverTimestamp(),
      'fear': 0,
      'actionTokens': 0,
      'combatants': [], 
    });

    await _enterRoomAsGm(code);
    return code;
  }

  // Riprendi una stanza esistente (dallo storico)
  Future<void> resumeRoom(String code) async {
    await _enterRoomAsGm(code);
  }

  // Logica interna per settare lo stato GM
  Future<void> _enterRoomAsGm(String code) async {
    currentRoomCode = code;
    isGm = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('room_code', code);
    await prefs.setBool('is_gm', true);
    await prefs.remove('char_id'); // Il GM non ha un character ID

    _listenToRoom(code);
    _listenToPlayers(code);
    notifyListeners();
  }

  // --- GM: GESTIONE COMBATTIMENTO & SYNC ---

  // Invia i dati locali (CombatProvider) al Cloud, convertendoli in JSON leggibili
  Future<void> syncCombatData(int newFear, int newTokens, List<dynamic> allCombatants) async {
    if (!isGm || currentRoomCode == null) return;

    List<Map<String, dynamic>> combatJson = allCombatants.map((e) {
      if (e is Character) {
        // --- È UN PERSONAGGIO ---
        return {
          'id': e.id,
          'name': e.name,
          'currentHp': e.currentHp,
          'maxHp': e.maxHp,
          'isPlayer': true,
          // Inviamo i dati essenziali
          ...e.toJson(), 
        };
      } else if (e is Adversary) {
        // --- È UN NEMICO (Adversary) ---
        return {
          'id': e.id,
          'name': e.name,
          'currentHp': e.currentHp,
          'maxHp': e.maxHp,
          'isPlayer': false, 
          
          // Dati specifici per il GM
          'tier': e.tier,
          'difficulty': e.difficulty,
          'attack': "${e.attackName} (+${e.attackMod})",
          'damage': e.damageDice,
          
          // Convertiamo la lista di oggetti Feature in lista di Mappe semplici
          'moves': e.features.map((f) => {
            'name': f.name,
            'description': f.text
          }).toList(),
        };
      } else {
        // Fallback di sicurezza
        return {
          'id': 'error',
          'name': 'Dati non validi',
          'isPlayer': false
        };
      }
    }).toList();

    await _db.collection('rooms').doc(currentRoomCode).update({
      'fear': newFear,
      'actionTokens': newTokens,
      'combatants': combatJson,
    });
  }

  // Pulisce il combattimento per tutti
  Future<void> clearCombat() async {
    if (!isGm || currentRoomCode == null) return;
    
    await _db.collection('rooms').doc(currentRoomCode).update({
      'combatants': [],
    });
  }

  // --- GIOCATORE: UNISCITI ---
  Future<void> joinRoom(String code, Character character) async {
    DocumentReference roomRef = _db.collection('rooms').doc(code);
    DocumentSnapshot snap = await roomRef.get();

    if (!snap.exists) throw Exception("Codice stanza non valido!");

    // Aggiunge/Aggiorna il player nella subcollection della stanza
    await roomRef.collection('players').doc(character.id).set(character.toJson());

    currentRoomCode = code;
    isGm = false;
    myCharacterId = character.id;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('room_code', code);
    await prefs.setBool('is_gm', false);
    await prefs.setString('char_id', character.id);

    _listenToRoom(code);
    notifyListeners();
  }

  // --- COMUNE: ESCI DALLA STANZA ---
  Future<void> exitRoom() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Manteniamo solo l'ID dispositivo, cancelliamo i dati di sessione
    String? deviceId = prefs.getString('user_device_id');
    await prefs.clear();
    
    // Ripristiniamo l'ID dispositivo fondamentale
    if (deviceId != null) {
      await prefs.setString('user_device_id', deviceId);
      myUserId = deviceId; // Reimpostiamo la variabile locale
    }
    
    // Reset stato locale
    currentRoomCode = null;
    isGm = false;
    myCharacterId = null;
    playersStream = null;
    activeCombatantsData = [];
    
    notifyListeners();
  }

  // --- ASCOLTATORI (LISTENERS) ---
  
  // Ascolta i cambiamenti generali (Paura, Token, Combattimento)
  void _listenToRoom(String code) {
    _db.collection('rooms').doc(code).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          fear = data['fear'] ?? 0;
          actionTokens = data['actionTokens'] ?? 0;
          activeCombatantsData = data['combatants'] ?? [];
          notifyListeners();
        }
      } else {
        // Se il documento viene cancellato mentre siamo dentro
        exitRoom();
      }
    });
  }

  // Ascolta la lista giocatori (Solo per GM)
  void _listenToPlayers(String code) {
    playersStream = _db.collection('rooms').doc(code).collection('players').snapshots();
    notifyListeners();
  }
}