import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- Necessario per Firestore
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'dart:convert';
import '../data/models/character.dart';
import '../data/data_manager.dart';

class CreationProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Variabile per l'ID utente (va impostata all'avvio o passata dai metodi)
  String? userId; 

  // Metodo per settare l'utente corrente (chiamalo dalla UI o dal main con il dato di RoomProvider)
  void setUserId(String id) {
    userId = id;
  }

  // --- Dati Temporanei (Wizard) ---
  Map<String, dynamic>? tempClass;
  Map<String, dynamic>? tempAncestry;
  Map<String, dynamic>? tempCommunity;
  Map<String, dynamic>? tempSubclass;
  
  Map<String, int> tempStats = {
    'agilita': 0, 'forza': 0, 'astuzia': 0, 
    'istinto': 0, 'presenza': 0, 'conoscenza': 0
  };

  final TextEditingController nameController = TextEditingController();
  final TextEditingController pronounsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  final Map<String, TextEditingController> backgroundControllers = {};
  final Map<String, TextEditingController> bondControllers = {};
  
  final List<TextEditingController> experienceControllers = [
    TextEditingController(), 
    TextEditingController()
  ];

  int selectedLoadoutIndex = 0;
  List<String> activeCardIds = [];
  int currentStep = 0;
  String? validationError;

  // --- GETTERS ---
  Map<String, dynamic>? get selectedClassData => tempClass;
  
  List<dynamic> get availableCards {
    if (tempClass == null) return [];
    if (tempClass!.containsKey('available_domains_filter')) {
        final domains = tempClass!['available_domains_filter']['valid_domains'] as List;
        return DataManager().getStartingCardsForDomains(domains);
    }
    return [];
  }

  Character get draftCharacter {
    return Character(
      id: 'draft',
      name: nameController.text.isNotEmpty ? nameController.text : 'Nuovo Eroe',
      classId: tempClass?['id'] ?? (tempClass?['name'] ?? ''),
      ancestryId: tempAncestry?['id'] ?? (tempAncestry?['name'] ?? ''),   
      communityId: tempCommunity?['id'] ?? (tempCommunity?['name'] ?? ''), 
      level: 1,
      stats: Map<String, int>.from(tempStats),
      inventory: [],
      activeCardIds: List<String>.from(activeCardIds), 
      currentHp: 10,
      maxHp: 10,
      currentStress: 0,
      maxStress: 5, 
      hope: 2,
      armorScore: 0,
      subclassId: tempSubclass?['id'],
      companion: (tempSubclass != null && tempSubclass!['id'] == 'ranger_beastbound') 
          ? {'name': 'Compagno', 'type': 'Animale'} : null,
    );
  }

  // --- ACTIONS ---
  void resetDraft() {
    tempClass = null; tempAncestry = null; tempCommunity = null; tempSubclass = null;
    tempStats = {'agilita': 0, 'forza': 0, 'astuzia': 0, 'istinto': 0, 'presenza': 0, 'conoscenza': 0};
    nameController.clear(); pronounsController.clear(); descriptionController.clear();
    backgroundControllers.clear(); bondControllers.clear();
    for (var c in experienceControllers) c.clear();
    selectedLoadoutIndex = 0; activeCardIds.clear(); currentStep = 0; validationError = null;
    notifyListeners();
  }

  void selectClass(String classId) {
    tempClass = DataManager().getClassById(classId);
    tempSubclass = null;
    activeCardIds.clear();
    tempStats = {'agilita': 0, 'forza': 0, 'astuzia': 0, 'istinto': 0, 'presenza': 0, 'conoscenza': 0};
    notifyListeners();
  }

  void selectSubclass(String id) {
    if (tempClass != null && tempClass!['subclasses'] != null) {
      final subs = tempClass!['subclasses'] as List;
      tempSubclass = subs.firstWhere((s) => s['id'] == id, orElse: () => null);
      notifyListeners();
    }
  }

  void selectAncestry(Map<String, dynamic> ancestry) {
    tempAncestry = ancestry;
    notifyListeners();
  }

  void selectCommunity(Map<String, dynamic> community) {
    tempCommunity = community;
    notifyListeners();
  }

  void updateTrait(String stat, int value) {
    if (tempStats.containsKey(stat)) {
      tempStats[stat] = value;
      if (validationError != null) validationError = null;
      notifyListeners();
    }
  }

  void selectLoadout(int index) { selectedLoadoutIndex = index; notifyListeners(); }
  
  void toggleCardSelection(String cardId) {
    if (activeCardIds.contains(cardId)) { 
      activeCardIds.remove(cardId); 
    } else { 
      if (activeCardIds.length < 2) activeCardIds.add(cardId); 
    }
    notifyListeners();
  }

  // --- VALIDAZIONE ---
  bool validateCurrentStep() {
    validationError = null;
    if (currentStep == 0 && tempClass == null) { validationError = "Seleziona una classe."; return false; }
    if (currentStep == 1 && tempAncestry == null) { validationError = "Seleziona un retaggio."; return false; }
    if (currentStep == 2 && tempCommunity == null) { validationError = "Seleziona una comunità."; return false; }
    if (currentStep == 3 && tempSubclass == null) { validationError = "Seleziona una sottoclasse."; return false; }
    if (currentStep == 4) return _validateTraitsLogic();
    return true; 
  }

  bool _validateTraitsLogic() {
    final requiredValues = [-1, 0, 0, 1, 1, 2];
    final currentValues = tempStats.values.toList();
    requiredValues.sort();
    currentValues.sort();
    if (!const ListEquality().equals(currentValues, requiredValues)) {
      validationError = "I valori non corrispondono all'array standard: -1, 0, 0, +1, +1, +2";
      notifyListeners();
      return false;
    }
    return true;
  }

  void nextStep() { if (validateCurrentStep()) { currentStep++; notifyListeners(); } }
  void prevStep() { if (currentStep > 0) { currentStep--; validationError = null; notifyListeners(); } }
  
  // --- SALVATAGGIO CLOUD ---
  Future<void> saveCharacter() async {
    if (tempClass == null || tempAncestry == null || tempCommunity == null) return;

    List<String> finalInventory = [];
    List<String> finalWeapons = [];
    String finalArmorName = "";
    int finalArmorScore = 0;

    if (tempClass != null && tempClass!['creation_guide'] != null) {
       final guide = tempClass!['creation_guide'];
       final loadouts = guide['starting_equipment_choices'] as List?;
       
       if (loadouts != null && selectedLoadoutIndex < loadouts.length) {
         final items = loadouts[selectedLoadoutIndex]['items'] as List;
         for (var item in items) {
           String type = item['type'];
           String name = item['name'];
           if (type == 'weapon') {
             finalWeapons.add(name);
           } else if (type == 'armor') {
             finalArmorName = name;
             finalArmorScore = 2; // Default
             if (item.toString().contains("Base 3")) finalArmorScore = 3;
           } else {
             finalInventory.add(name);
           }
         }
       }
    }
    
    Map<String, String> narrative = {};
    backgroundControllers.forEach((k, v) => narrative[k] = v.text);
    bondControllers.forEach((k, v) => narrative[k] = v.text);

    final newChar = Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.isNotEmpty ? nameController.text : 'Senza Nome',
      classId: tempClass!['id'] ?? tempClass!['name'],
      ancestryId: tempAncestry!['id'] ?? tempAncestry!['name'],
      communityId: tempCommunity!['id'] ?? tempCommunity!['name'],
      level: 1,
      stats: Map<String, int>.from(tempStats),
      inventory: finalInventory,
      weapons: finalWeapons,
      activeCardIds: List<String>.from(activeCardIds),
      currentHp: 6, maxHp: 6, currentStress: 0, 
      maxStress: (tempAncestry!['id'] == 'human' || tempAncestry!['name'] == 'Umano') ? 6 : 5,
      armorName: finalArmorName, armorScore: finalArmorScore, armorSlotsUsed: 0, evasionModifier: 0,
      hope: 2, gold: 0, subclassId: tempSubclass?['id'],
      pronouns: pronounsController.text, description: descriptionController.text, narrativeAnswers: narrative,
      experiences: experienceControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
      companion: (tempSubclass != null && tempSubclass!['id'] == 'ranger_beastbound') 
        ? {'name': 'Compagno', 'type': 'Animale', 'currentStress': 0, 'maxStress': 5} : null,
    );

    // 1. Salvataggio Locale (Backup)
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('saved_characters') ?? [];
    savedList.add(jsonEncode(newChar.toJson()));
    await prefs.setStringList('saved_characters', savedList);

    // 2. Salvataggio Cloud (Principale)
    if (userId != null) {
      try {
        await _db.collection('users')
            .doc(userId)
            .collection('characters')
            .doc(newChar.id)
            .set(newChar.toJson());
        print("Personaggio salvato su Cloud per utente $userId");
      } catch (e) {
        print("Errore salvataggio Cloud: $e");
      }
    } else {
      print("WARNING: UserId nullo, salvataggio solo locale.");
    }

    notifyListeners();
  }
  
  // Eliminazione
  Future<void> deleteCharacter(String charId) async {
    // Locale
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('saved_characters') ?? [];
    savedList.removeWhere((s) {
        try { return jsonDecode(s)['id'] == charId; } catch (e) { return false; }
    });
    await prefs.setStringList('saved_characters', savedList);

    // Cloud
    if (userId != null) {
      try {
        await _db.collection('users')
            .doc(userId)
            .collection('characters')
            .doc(charId)
            .delete();
      } catch (e) {
        print("Errore eliminazione Cloud: $e");
      }
    }
    notifyListeners();
  }
  
  // Caricamento Ibrido (Cloud priority, fallback locale)
  Future<List<Character>> loadSavedCharacters() async {
    List<Character> characters = [];

    // 1. Prova a caricare dal Cloud
    if (userId != null) {
      try {
        final snap = await _db.collection('users')
            .doc(userId)
            .collection('characters')
            .get();
        
        if (snap.docs.isNotEmpty) {
          characters = snap.docs.map((doc) => Character.fromJson(doc.data())).toList();
          print("Caricati ${characters.length} personaggi dal Cloud.");
          
          // Sincronizza Cloud -> Locale (Opzionale, ma utile per offline)
          // ... (logica di sync omessa per brevità)
          return characters; 
        }
      } catch (e) {
        print("Errore caricamento Cloud: $e. Tento locale.");
      }
    }

    // 2. Fallback Locale (se cloud fallisce o è vuoto)
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('saved_characters') ?? [];
    if (characters.isEmpty && savedList.isNotEmpty) {
       characters = savedList.map((e) {
        try { return Character.fromJson(jsonDecode(e)); } catch(_) { return null; }
      }).whereType<Character>().toList();
    }
    
    return characters;
  }
}