import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/character_options.dart';
import '../models/domain_card.dart';
import '../models/equipment.dart';

// Questi file verranno generati automaticamente
part 'character_state.freezed.dart';
part 'character_state.g.dart';

/// IL MODELLO DEL PERSONAGGIO (STATO)
@freezed
class CharacterDraft with _$CharacterDraft {
  const factory CharacterDraft({
    @Default("New Character") String name,
    
    // Le scelte principali
    DaggerheartClass? selectedClass,
    Subclass? subclass,
    Ancestry? ancestry,
    Community? community,
    Weapon? primaryWeapon,
    Weapon? secondaryWeapon,
    Armor? selectedArmor,
    
    // Carte Dominio (Nuovo campo)
    @Default([]) List<DomainCard> selectedDomainCards,
    
    // Attributi (Stats)
    @Default(0) int agility,
    @Default(0) int strength,
    @Default(0) int finesse,
    @Default(0) int instinct,
    @Default(0) int presence,
    @Default(0) int knowledge,

    // Stato di gioco
    @Default(6) int maxHp,
    @Default(6) int currentHp,
    @Default(0) int stress,
    @Default(2) int hope,
    @Default(10) int evasion,
    
    // Livello
    @Default(1) int level,
    // NUOVI CAMPI PER BACKGROUND & LORE
    @Default([]) List<String> startingItems, // L'oggetto scelto dall'inventario
    @Default({}) Map<String, String> backgroundAnswers, // Domanda -> Risposta
    @Default({}) Map<String, String> connectionAnswers, // Domanda -> Risposta
  }) = _CharacterDraft;

  factory CharacterDraft.fromJson(Map<String, dynamic> json) => _$CharacterDraftFromJson(json);
}

/// IL GESTORE DELLO STATO (LOGICA)
class CharacterNotifier extends StateNotifier<CharacterDraft> {
  CharacterNotifier() : super(const CharacterDraft());

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  /// Quando scegli la Classe, impostiamo automaticamente anche HP ed Evasione base
  /// Inoltre resettiamo Sottoclasse e Carte Dominio, perché dipendono dalla Classe.
  void setClass(DaggerheartClass c) {
    state = state.copyWith(
      selectedClass: c,
      subclass: null, // Reset della sottoclasse
      selectedDomainCards: [], // Reset delle carte dominio
      maxHp: c.startingHitPoints,
      currentHp: c.startingHitPoints,
      // Calcola Evasione: Base della classe + Agilità attuale
      evasion: c.startingEvasion + state.agility,
    );
  }

  /// Imposta la Sottoclasse
  void setSubclass(Subclass s) {
    state = state.copyWith(subclass: s);
  }

  void setAncestry(Ancestry a) {
    state = state.copyWith(ancestry: a);
  }

  void setCommunity(Community c) {
    state = state.copyWith(community: c);
  }

  /// Gestione Carte Dominio: Aggiunge o Rimuove una carta
  void toggleDomainCard(DomainCard card) {
    // Creiamo una copia modificabile della lista
    final currentCards = state.selectedDomainCards.toList();
    
    // Controlliamo se la carta è già presente tramite ID
    final index = currentCards.indexWhere((c) => c.id == card.id);

    if (index >= 0) {
      // Se c'è, la rimuoviamo
      currentCards.removeAt(index);
    } else {
      // Se non c'è, la aggiungiamo
      // (Qui potremmo aggiungere un controllo per max 2 carte, ma lo gestiremo nella UI per ora)
      currentCards.add(card);
    }
    
    state = state.copyWith(selectedDomainCards: currentCards);
  }

  /// Imposta tutti gli attributi in una volta (Array Standard) e ricalcola l'Evasione
  void setAllAttributes({
    required int agility,
    required int strength,
    required int finesse,
    required int instinct,
    required int presence,
    required int knowledge,
  }) {
    // Recupera l'evasione base della classe (o 10 se non c'è classe)
    final int baseEvasion = state.selectedClass?.startingEvasion ?? 10;

    state = state.copyWith(
      agility: agility,
      strength: strength,
      finesse: finesse,
      instinct: instinct,
      presence: presence,
      knowledge: knowledge,
      // Ricalcolo Automatico Derivati
      evasion: baseEvasion + agility,
    );
  }

  /// Aggiorna un singolo attributo (utile per modifiche manuali future)
  void setAttribute(String key, int value) {
    // Se modifichiamo l'agilità, dobbiamo aggiornare anche l'evasione
    if (key.toLowerCase() == 'agility') {
      final int baseEvasion = state.selectedClass?.startingEvasion ?? 10;
      state = state.copyWith(
        agility: value,
        evasion: baseEvasion + value,
      );
      return;
    }

    switch (key.toLowerCase()) {
      case 'strength': state = state.copyWith(strength: value); break;
      case 'finesse': state = state.copyWith(finesse: value); break;
      case 'instinct': state = state.copyWith(instinct: value); break;
      case 'presence': state = state.copyWith(presence: value); break;
      case 'knowledge': state = state.copyWith(knowledge: value); break;
    }
  }
  void setPrimaryWeapon(Weapon w) {
  state = state.copyWith(primaryWeapon: w);
  }

  void setSecondaryWeapon(Weapon w) {
  state = state.copyWith(secondaryWeapon: w);
  }

  void setArmor(Armor a) {
  state = state.copyWith(selectedArmor: a);
  }

  void setStartingItem(int index, String item) {
    // Crea una copia modificabile della lista attuale
    List<String> newItems = List.from(state.startingItems);
    
    // Assicuriamoci che la lista sia abbastanza lunga
    if (newItems.length <= index) {
      // Riempiamo con stringhe vuote se necessario fino all'indice desiderato
      while (newItems.length <= index) {
        newItems.add("");
      }
    }
    
    // Imposta l'oggetto all'indice specifico (es. indice 0 = Pozioni, indice 1 = Oggetto narrativo)
    newItems[index] = item;
    
    state = state.copyWith(startingItems: newItems);
  }

  void setBackgroundAnswer(String question, String answer) {
    // Aggiorna la mappa delle risposte mantenendo le altre
    final newMap = Map<String, String>.from(state.backgroundAnswers);
    newMap[question] = answer;
    state = state.copyWith(backgroundAnswers: newMap);
  }

  void setConnectionAnswer(String question, String answer) {
    final newMap = Map<String, String>.from(state.connectionAnswers);
    newMap[question] = answer;
    state = state.copyWith(connectionAnswers: newMap);
  }


  void modifyHp(int delta) {
    int newValue = (state.currentHp + delta).clamp(0, state.maxHp);
    state = state.copyWith(currentHp: newValue);
  }

  void modifyStress(int delta) {
    state = state.copyWith(stress: (state.stress + delta).clamp(0, 10)); 
  }
  
  void modifyHope(int delta) {
     state = state.copyWith(hope: (state.hope + delta).clamp(0, 99));
  }

  void reset() {
    state = const CharacterDraft();
  }
  
  void loadCharacter(CharacterDraft char) {
    state = char;
  }
}

final characterProvider = StateNotifierProvider<CharacterNotifier, CharacterDraft>((ref) {
  return CharacterNotifier();
});