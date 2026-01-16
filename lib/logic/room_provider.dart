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
  
  // --- IDENTITÀ UTENTE (UNIFICATA) ---
  // Questo ID rappresenta la persona fisica, sia essa GM o Giocatore.
  String? myUserId; 

  // --- STATO SESSIONE CORRENTE ---
  String? currentRoomCode;
  bool isGm = false;
  String? myCharacterId;  

  // --- DATI STANZA ATTIVA ---
  int fear = 0;
  int actionTokens = 0;
  List<dynamic> activeCombatantsData = []; 
  
  // Lista stanze create (se sono GM)
  List<Map<String, dynamic>> myRooms = [];
  
  Stream<QuerySnapshot>? playersStream;

  // Getter di compatibilità per UI
  String? get userId => myUserId;

  // --- 1. INIZIALIZZAZIONE ---
  // Chiamato all'avvio dell'app (StartupScreen)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // A. Gestione Identità Unica
    if (!prefs.containsKey('user_device_id')) {
      String newId = const Uuid().v4();
      await prefs.setString('user_device_id', newId);
    }
    myUserId = prefs.getString('user_device_id');

    // B. Tentativo di Riconnessione Sessione (se l'app è stata chiusa mentre si giocava)
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
            // Se stavo facendo il GM, ricarico le mie stanze
            loadMyRooms(); 
          }
        } else {
          // Stanza non esiste più
          await exitRoom();
        }
      } catch (e) {
        print("Errore riconnessione: $e");
        await exitRoom();
      }
    }
    notifyListeners();
  }

  // Metodo alias per compatibilità con UI
  Future<void> initUser() async => await init();

  // --- 2. GESTIONE IDENTITÀ (RECUPERO) ---
  // Permette di inserire un ID salvato altrove per recuperare l'account
  Future<void> forceUserId(String newId) async {
    myUserId = newId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_device_id', newId);
    
    // Dopo aver cambiato ID, ricarico le stanze associate a questo nuovo ID
    await loadMyRooms();
    notifyListeners();
  }

  // --- 3. LOGICA GM (CREAZIONE & GESTIONE) ---

  // Carica le stanze dove 'gmId' corrisponde al MIO 'myUserId'
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
        'gmId': myUserId, // Qui leghiamo la stanza all'Utente
        'createdAt': FieldValue.serverTimestamp(),
        'fear': 0,
        'actionTokens': 0,
        'combatants': [],
        'players': [] 
      });

      // Entra subito come GM
      await _enterRoomAsGm(code);
      // Aggiorna la lista
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

  // --- 4. LOGICA GIOCATORE (JOIN) ---
  
  Future<bool> joinRoom(String code, Character character) async {
    if (myUserId == null) await init();

    try {
      // Nota: Potremmo passare myUserId qui per legare il personaggio all'utente
      // Ma per ora manteniamo la logica semplice del servizio
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

  // --- 5. COMBATTIMENTO & SYNC (GM) ---
  // Questa parte rimane invariata, serve al GM per aggiornare il DB

  Future<void> syncCombatData(int newFear, int newTokens, List<dynamic> allCombatants) async {
    if (!isGm || currentRoomCode == null) return;

    List<Map<String, dynamic>> combatJson = allCombatants.map((e) {
      if (e is Character) {
        return {
          'id': e.id, 'name': e.name, 'currentHp': e.currentHp, 'maxHp': e.maxHp,
          'isPlayer': true, ...e.toJson(), 
        };
      } else if (e is Adversary) {
        return {
          'id': e.id, 'name': e.name, 'currentHp': e.currentHp, 'maxHp': e.maxHp,
          'isPlayer': false, 'tier': e.tier, 'difficulty': e.difficulty,
          'attack': "${e.attackName} (+${e.attackMod})", 'damage': e.damageDice,
          'moves': e.features.map((f) => {'name': f.name, 'description': f.text}).toList(),
        };
      } else {
        return {'id': 'error', 'name': '?', 'isPlayer': false};
      }
    }).toList();

    await _db.collection('rooms').doc(currentRoomCode).update({
      'fear': newFear, 'actionTokens': newTokens, 'combatants': combatJson,
    });
  }

  Future<void> clearCombat() async {
    if (!isGm || currentRoomCode == null) return;
    await _db.collection('rooms').doc(currentRoomCode).update({'combatants': []});
  }

  // --- 6. USCITA (EXIT) ---

  // Esce dalla stanza (ma mantiene l'identità utente)
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
    
    // Se esco, ricarico le mie stanze per aggiornare la dashboard GM se rientro lì
    if (myUserId != null) loadMyRooms();
    
    notifyListeners();
  }

  // Resetta totalmente l'identità (per debug o cambio totale)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_device_id'); // Cancella l'ID utente
    await exitRoom();
    myUserId = null;
    myRooms = [];
    notifyListeners();
  }

  // --- LISTENERS ---
  
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