import 'package:flutter/material.dart';
import '../data/models/character.dart';
import '../data/models/adversary.dart';

class CombatProvider extends ChangeNotifier {
  // Liste locali per gestire i partecipanti allo scontro
  List<Character> activeCharacters = [];
  List<Adversary> activeEnemies = [];

  // --- GESTIONE EROI ---

  /// Aggiunge un personaggio allo scontro
  void addCharacter(Character char) {
    // Evita duplicati controllando l'ID
    if (!activeCharacters.any((c) => c.id == char.id)) {
      activeCharacters.add(char);
      notifyListeners();
    }
  }

  /// Rimuove un personaggio dallo scontro
  void removeCharacter(String id) {
    activeCharacters.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // --- GESTIONE AVVERSARI ---

  /// Aggiunge un avversario allo scontro
  void addAdversary(Adversary adv) {
    // Genera un ID univoco temporaneo se necessario per distinguere più mostri dello stesso tipo
    if (adv.id.isEmpty || activeEnemies.any((e) => e.id == adv.id)) {
      // Creiamo una "copia" con un nuovo ID se possibile, oppure usiamo l'oggetto così com'è
      // (Assumendo che l'ID venga gestito esternamente o che vada bene così per ora)
    }
    activeEnemies.add(adv);
    notifyListeners();
  }

  /// Rimuove un avversario dallo scontro
  void removeAdversary(String id) {
    activeEnemies.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // --- GESTIONE HP E STATO ---

  /// Modifica i Punti Ferita di un'entità (Eroe o Nemico)
  void modifyHp(String id, int delta) {
    // 1. Cerca nei nemici
    for (var enemy in activeEnemies) {
      if (enemy.id == id) {
        int newHp = (enemy.currentHp + delta).clamp(0, enemy.maxHp);
        enemy.currentHp = newHp; // Aggiornamento diretto (se il campo è mutabile)
        notifyListeners();
        return;
      }
    }
    
    // 2. Cerca negli eroi
    for (var char in activeCharacters) {
      if (char.id == id) {
        int newHp = (char.currentHp + delta).clamp(0, char.maxHp);
        char.currentHp = newHp;
        notifyListeners();
        return;
      }
    }
  }

  /// Pulisce tutto lo scontro
  void clearCombat() {
    activeCharacters.clear();
    activeEnemies.clear();
    notifyListeners();
  }

  /// Carica uno stato esistente (utile se si riprende un combattimento dal DB)
  void loadCombatState(List<dynamic> combatants) {
    activeCharacters.clear();
    activeEnemies.clear();

    for (var c in combatants) {
      if (c is Character) {
        activeCharacters.add(c);
      } else if (c is Adversary) {
        activeEnemies.add(c);
      } else if (c is Map<String, dynamic>) {
        // Parsing manuale se arriva come JSON puro
        if (c['isPlayer'] == true) {
          try {
            activeCharacters.add(Character.fromJson(c));
          } catch (e) {
            print("Errore parsing Character: $e");
          }
        } else {
          try {
            activeEnemies.add(Adversary.fromJson(c));
          } catch (e) {
            print("Errore parsing Adversary: $e");
          }
        }
      }
    }
    notifyListeners();
  }
}