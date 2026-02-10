import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_options.dart';
import '../models/domain_card.dart';
import '../models/equipment.dart';

/// Questo Provider è il punto di accesso per l'intera app.
/// L'UI ascolterà "dataLoaderFuture". Se è in caricamento -> mostra rotellina.
/// Se ha finito -> mostra la schermata.
final dataRepositoryProvider = Provider((ref) => DataRepository());

final dataLoaderFuture = FutureProvider<void>((ref) async {
  final repo = ref.read(dataRepositoryProvider);
  await repo.loadAllData();
});

class DataRepository {
  // Liste che conterranno i dati caricati
  List<DaggerheartClass> classes = [];
  List<Ancestry> ancestries = [];
  List<Community> communities = [];
  List<Subclass> subclasses = [];
  List<DomainCard> domainCards = [];
  List<Weapon> weapons = [];
  List<Armor> armors = [];

  /// Metodo principale chiamato all'avvio
  Future<void> loadAllData() async {
    // Carichiamo parallelamente sia i file CORE che i file THE VOID (se presenti)
    // Usiamo Future.wait per caricarli tutti insieme e non uno dopo l'altro (più veloce)
    
    // 1. CLASSI (Gestisce formato Mappa)
    final classesData = await Future.wait([
      _loadList('assets/data/core/classes.json', (json) => DaggerheartClass.fromJson(json)),
      _loadList('assets/data/the_void/classes.json', (json) => DaggerheartClass.fromJson(json)),
    ]);
    classes = classesData.expand((i) => i).toList();

    // 2. ANCESTRIES (Gestisce formato Lista)
    final ancestriesData = await Future.wait([
      _loadList('assets/data/core/ancestries.json', (json) => Ancestry.fromJson(json)),
      _loadList('assets/data/the_void/ancestries.json', (json) => Ancestry.fromJson(json)),
    ]);
    ancestries = ancestriesData.expand((i) => i).toList();

    // 3. COMMUNITIES (Gestisce formato Lista)
    final communitiesData = await Future.wait([
      _loadList('assets/data/core/communities.json', (json) => Community.fromJson(json)),
      _loadList('assets/data/the_void/communities.json', (json) => Community.fromJson(json)),
    ]);
    communities = communitiesData.expand((i) => i).toList();
    // 4. SUBCLASSES (Nuovo blocco)
    final subclassesData = await Future.wait([
      _loadList('assets/data/core/subclasses.json', (json) => Subclass.fromJson(json)),
      _loadList('assets/data/the_void/subclasses.json', (json) => Subclass.fromJson(json)),
    ]);
    subclasses = subclassesData.expand((i) => i).toList();
    // 5. DOMAIN CARDS (Nuovo blocco)
    final cardsData = await Future.wait([
      _loadList('assets/data/core/domain-cards.json', (json) => DomainCard.fromJson(json)),
      _loadList('assets/data/the_void/domain-cards.json', (json) => DomainCard.fromJson(json)),
    ]);
    domainCards = cardsData.expand((i) => i).toList();

    // 6. WEAPONS
    final weaponsData = await Future.wait([
      _loadList('assets/data/core/weapons.json', (json) => Weapon.fromJson(json)),
      _loadList('assets/data/the_void/weapons.json', (json) => Weapon.fromJson(json)),
    ]);
    weapons = weaponsData.expand((i) => i).toList();

    // 7. ARMORS
    final armorsData = await Future.wait([
      _loadList('assets/data/core/armors.json', (json) => Armor.fromJson(json)),
      _loadList('assets/data/the_void/armors.json', (json) => Armor.fromJson(json)),
    ]);
    armors = armorsData.expand((i) => i).toList();


    print("--- DATA LOADED ---");
    print("Classes: ${classes.length}");
    print("Subclasses: ${subclasses.length}");
    print("Ancestries: ${ancestries.length}");
    print("Communities: ${communities.length}");
    print("Domain Cards: ${domainCards.length}");
    print("Weapons: ${weapons.length}");
    print("Armors: ${armors.length}");
  }

  /// Helper generico per caricare un file JSON e convertirlo in Lista di Oggetti
  /// Ora gestisce sia formati LISTA [..] che formati MAPPA {"ID": {..}}
  Future<List<T>> _loadList<T>(
    String path, 
    T Function(Map<String, dynamic>) fromJson
  ) async {
    try {
      // Legge il file come stringa
      final String response = await rootBundle.loadString(path);
      // Decodifica il JSON come dynamic per controllare il tipo
      final dynamic data = json.decode(response);

      // CASO A: Il JSON è una Lista standard [ {}, {} ]
      // (Funziona per Ancestries e Communities)
      if (data is List) {
        return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      } 
      
      // CASO B: Il JSON è una Mappa { "BARD": {}, "WIZARD": {} }
      // (Funziona per le Classi)
      else if (data is Map) {
        // Prendiamo solo i "valori" della mappa (gli oggetti), ignorando le chiavi esterne
        return data.values.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      }

      print("Warning: $path ha un formato sconosciuto (né Lista né Mappa).");
      return [];

    } catch (e) {
      // Se il file non esiste o è rotto, non crashare tutto, ritorna lista vuota
      // Questo è utile se ad esempio rimuovi la cartella "the_void" in futuro
      print("Warning: Could not load $path. Error: $e");
      return [];
    }
  }
}