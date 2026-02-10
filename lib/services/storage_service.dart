import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/character_state.dart';

class StorageService {
  static const String _key = 'daggerheart_characters';

  // Salva un nuovo personaggio
  static Future<void> saveCharacter(CharacterDraft character) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Recupera la lista esistente
    final List<String> savedList = prefs.getStringList(_key) ?? [];
    
    // 2. Converti il nuovo personaggio in JSON
    final String charJson = jsonEncode(character.toJson());
    
    // 3. Aggiungi e salva
    savedList.add(charJson);
    await prefs.setStringList(_key, savedList);
  }

  // Carica tutti i personaggi
  static Future<List<CharacterDraft>> loadCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList(_key) ?? [];

    return savedList.map((str) {
      try {
        return CharacterDraft.fromJson(jsonDecode(str));
      } catch (e) {
        print("Errore nel decodificare un personaggio: $e");
        return null;
      }
    }).whereType<CharacterDraft>().toList();
  }

  // Elimina un personaggio (per indice)
  static Future<void> deleteCharacter(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList(_key) ?? [];
    
    if (index >= 0 && index < savedList.length) {
      savedList.removeAt(index);
      await prefs.setStringList(_key, savedList);
    }
  }
  static Future<void> updateCharacter(CharacterDraft char) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList(_key) ?? [];
    
    // Trova l'indice del personaggio con lo stesso nome (o ID se l'avessimo usato)
    // Nota: questo assume che il nome sia univoco. In futuro meglio usare un ID.
    int index = -1;
    for (int i = 0; i < savedList.length; i++) {
      final existing = CharacterDraft.fromJson(jsonDecode(savedList[i]));
      if (existing.name == char.name) {
        index = i;
        break;
      }
    }

    if (index != -1) {
      // Aggiorna
      savedList[index] = jsonEncode(char.toJson());
    } else {
      // Se non trovato, aggiungi come nuovo
      savedList.add(jsonEncode(char.toJson()));
    }
    
    await prefs.setStringList(_key, savedList);
  }
}