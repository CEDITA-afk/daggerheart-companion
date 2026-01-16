import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; 
import 'dart:math';
import '../data/models/character.dart';
import '../data/models/adversary.dart';
import 'room_service.dart';

class RoomProvider extends ChangeNotifier {
  final RoomService _service = RoomService();
  
  // Getter lazy per Firebase
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  
  // --- STATO SESSIONE ---
  String? currentRoomCode;
  bool isGm = false;
  
  // Identificativo Utente (Usiamo 'myUserId' come nella versione originale)
  String? myUserId;       
  String? myCharacterId;  

  // --- COMPATIBILITÀ UI (Fix per gli errori) ---
  // L'interfaccia chiede 'userId', noi glielo diamo collegandolo a 'myUserId'
  String? get userId => myUserId;
  
  // L'interfaccia chiede 'initUser', noi chiamiamo 'init'
  Future<void> initUser() async => await init();

  // Liste per la gestione stanze (GM)
  List<Map<String, dynamic>> myRooms = [];

  // Dati della stanza
  int fear = 0;
  int actionTokens = 0;
  List<dynamic> activeCombatantsData = []; 
  
  Stream<QuerySnapshot>? playersStream;

  // --- 1. INIZIALIZZAZIONE ---
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // A. Identità del Dispositivo
    // NOTA: Usiamo la chiave 'user_device_id' per mantenere la memoria storica se presente
    if (!prefs.containsKey('user_device_id')) {
      String newId = const Uuid().v4();
      await prefs.setString('user_device_id', newId);
    }
    myUserId = prefs.getString('user_device_id');

    // B. Controllo Sessione Interrotta
    final savedRoom = prefs.getString('room_code');
    final savedIsGm = prefs.getBool('is_gm') ?? false;
    final savedCharId = prefs.getString('char_id');

    if (savedRoom != null) {
      try {
        DocumentSnapshot snap = await _db.collection('rooms').doc(savedRoom).get();
        if (snap.exists) {
          currentRoomCode = savedRoom;
          isGm = savedIsGm;
          myCharacterId = savedCharId;
          
          _listenToRoom(savedRoom);
          if (isGm) {
            _listenToPlayers(savedRoom);
            loadMyRooms(); 
          }
          notifyListeners();
        } else {
          await exitRoom();
        }
      } catch (e) {
        print("Errore riconnessione: $e");
        await exitRoom();
      }
    }
    notifyListeners();
  }

  // --- METODO RECUPERO ID (Fix Errori Compilazione) ---
  Future<void> forceUserId(String newId) async {
    // Aggiorna la variabile locale corretta
    myUserId = newId; 
    
    final prefs = await SharedPreferences.getInstance();
    // Usa la chiave corretta 'user_device_id' coerente con init()
    await prefs.setString('user_device_id', newId); 
    
    // Ricarica le stanze per il nuovo ID
    await loadMyRooms();
    
    notifyListeners();
  }

  // --- 2. GESTIONE STANZE GM ---

  Future<void> loadMyRooms() async {
    if (myUserId == null) await init(); 
    try {
      myRooms = await _service.getRoomsForGm(myUserId!);
      notifyListeners();
    } catch (e) {
      print("Errore caricamento stanze GM: $e");
    }
  }

  Future<String?> createRoom(String roomName, {String gmName = 'Game Master'}) async {
    if (myUserId == null) await init();

    try {
      String code = _generateRoomCode();
      
      await _db.collection('rooms').doc(code).set({
        'code': code,
        'roomName': roomName,
        'gmName': gmName,
        'gmId': myUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'fear': 0,
        'actionTokens': 0,
        'combatants': [],
        'players': [] 
      });

      await _enterRoomAsGm(code);
      await loadMyRooms();
      
      return code;
    } catch (e) {
      print("Errore creazione stanza: $e");
      return null;
    }
  }

  Future<void> resumeRoom(String code) async {
    await _enterRoomAsGm(code);
  }

  Future<void> _enterRoomAsGm(String code) async {
    currentRoomCode = code;
    isGm = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('room_code', code);
    await prefs.setBool('is_gm', true);
    await prefs.remove('char_id');

    _listenToRoom(code);
    _listenToPlayers(code);
    notifyListeners();
  }

  // --- 3. GESTIONE GIOCATORE ---
  
  Future<bool> joinRoom(String code, Character character) async {
    if (myUserId == null) await init();

    try {
      bool success = await _service.joinRoom(code, character.id, character.name);
      
      if (!success) return false;

      currentRoomCode = code;
      isGm = false;
      myCharacterId = character.id;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('room_code', code);
      await prefs.setBool('is_gm', false);
      await prefs.setString('char_id', character.id);

      _listenToRoom(code);
      notifyListeners();
      return true;
    } catch (e) {
      print("Errore join room: $e");
      return false;
    }
  }

  // --- 4. COMBATTIMENTO & SYNC ---

  Future<void> syncCombatData(int newFear, int newTokens, List<dynamic> allCombatants) async {
    if (!isGm || currentRoomCode == null) return;

    List<Map<String, dynamic>> combatJson = allCombatants.map((e) {
      if (e is Character) {
        return {
          'id': e.id,
          'name': e.name,
          'currentHp': e.currentHp,
          'maxHp': e.maxHp,
          'isPlayer': true,
          ...e.toJson(), 
        };
      } else if (e is Adversary) {
        return {
          'id': e.id,
          'name': e.name,
          'currentHp': e.currentHp,
          'maxHp': e.maxHp,
          'isPlayer': false, 
          'tier': e.tier,
          'difficulty': e.difficulty,
          'attack': "${e.attackName} (+${e.attackMod})",
          'damage': e.damageDice,
          'moves': e.features.map((f) => {'name': f.name, 'description': f.text}).toList(),
        };
      } else {
        return {'id': 'error', 'name': 'Dati non validi', 'isPlayer': false};
      }
    }).toList();

    await _db.collection('rooms').doc(currentRoomCode).update({
      'fear': newFear,
      'actionTokens': newTokens,
      'combatants': combatJson,
    });
  }

  Future<void> clearCombat() async {
    if (!isGm || currentRoomCode == null) return;
    await _db.collection('rooms').doc(currentRoomCode).update({
      'combatants': [],
    });
  }

  // --- 5. LOGOUT / USCITA ---

  Future<void> exitRoom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('room_code');
    await prefs.remove('is_gm');
    await prefs.remove('char_id');
    
    currentRoomCode = null;
    isGm = false;
    myCharacterId = null;
    playersStream = null;
    activeCombatantsData = [];
    
    if (myUserId != null) loadMyRooms();
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_device_id');
    await exitRoom();
    myUserId = null;
    myRooms = [];
    notifyListeners();
  }

  // --- 6. LISTENER ---
  
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
        exitRoom();
      }
    });
  }

  void _listenToPlayers(String code) {
    playersStream = _db.collection('rooms').doc(code).collection('players').snapshots();
    notifyListeners();
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}