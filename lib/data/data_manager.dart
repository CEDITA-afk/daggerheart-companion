import 'dart:convert';
import 'dart:typed_data'; // Serve per gestire i byte grezzi
import 'package:flutter/services.dart';
import 'models/adversary.dart'; 

class DataManager {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  // Liste Dati Private
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _races = []; 
  List<Map<String, dynamic>> _communities = []; 
  List<Map<String, dynamic>> _cards = []; 
  List<dynamic> _adversaries = []; 
  List<Map<String, dynamic>> _commonItems = []; 

  // --- GETTERS PUBBLICI ---
  List<Map<String, dynamic>> get classes => _classes;
  List<Map<String, dynamic>> get races => _races;             
  List<Map<String, dynamic>> get communities => _communities;
  List<Map<String, dynamic>> get domainCards => _cards;
  List<dynamic> get adversaries => _adversaries;
  List<Map<String, dynamic>> get commonItems => _commonItems;

  // --- METODI DI RICERCA ---
  Map<String, dynamic>? getClassById(String id) {
    return _classes.firstWhere(
      (c) => c['name'].toString().toLowerCase() == id.toLowerCase() || 
             (c['id'] != null && c['id'].toString().toLowerCase() == id.toLowerCase()),
      orElse: () => {},
    );
  }

  Map<String, dynamic>? getAncestryById(String id) {
    return _races.firstWhere(
      (r) => r['name'].toString().toLowerCase() == id.toLowerCase() ||
             (r['id'] != null && r['id'].toString().toLowerCase() == id.toLowerCase()),
      orElse: () => {'name': id, 'description': ''}, 
    );
  }

  Map<String, dynamic>? getCommunityById(String id) {
    return _communities.firstWhere(
      (c) => c['name'].toString().toLowerCase() == id.toLowerCase() ||
             (c['id'] != null && c['id'].toString().toLowerCase() == id.toLowerCase()),
      orElse: () => {'name': id, 'description': ''},
    );
  }

  Map<String, dynamic>? getCardById(String id) {
    return _cards.firstWhere(
      (c) => c['id'].toString() == id,
      orElse: () => {'name': 'Carta Sconosciuta', 'description': ''},
    );
  }
  
  Map<String, dynamic> getItemStats(String name) {
    try {
      return _commonItems.firstWhere(
        (i) => i['name'].toString().toLowerCase() == name.toLowerCase(),
        orElse: () => {'name': name, 'description': '-'}
      );
    } catch (e) {
      return {'name': name, 'description': '-'};
    }
  }
  
  List<Map<String, dynamic>> getStartingCardsForDomains(List<dynamic> domains) {
    return _cards.where((card) {
      return domains.contains(card['domain']) && (card['level'] == 1 || card['level'] == 0);
    }).toList();
  }

  List<Adversary> getAdversaryLibrary() {
    return _adversaries.map((json) {
      try {
        return Adversary.fromJson(json);
      } catch (e) {
        return null;
      }
    }).whereType<Adversary>().toList();
  }

  // --- CARICAMENTO DATI ---
  Future<void> loadAllData() async {
    try {
      _classes = await _loadClassFiles(); 
      _races = await _loadJsonFile('assets/data/razze.json');
      _communities = await _loadJsonFile('assets/data/comunita.json');
      _cards = await _loadJsonFile('assets/data/carte_domini.json');
      
      _adversaries = [];
      List<String> advFiles = [
        'assets/data/adversaries/base_tier0.json',
        'assets/data/adversaries/the_void_1_5.json',
        'assets/data/adversaries/age_of_umbra.json'
      ];
      for (var file in advFiles) {
        try {
          var content = await _loadJsonFile(file);
          _adversaries.addAll(content);
        } catch (e) {
           // Ignora errori file singoli
        }
      }
      
    } catch (e) {
      print("CRITICAL ERROR DataManager LoadAll: $e");
    }
  }

  // --- METODO DI CARICAMENTO ROBUSTO (FIX ENCODING) ---
  Future<List<Map<String, dynamic>>> _loadJsonFile(String path) async {
    try {
      // 1. Carichiamo i byte grezzi (non la stringa decodificata)
      final ByteData rawData = await rootBundle.load(path);
      final List<int> bytes = rawData.buffer.asUint8List();
      
      String response;
      try {
        // 2. Proviamo a decodificare come UTF-8 (Standard JSON)
        response = utf8.decode(bytes);
      } catch (_) {
        // 3. Se fallisce (perché ci sono accenti Windows-1252), usiamo Latin-1
        print("Warning: $path non è UTF-8 valido. Tentativo fallback Latin-1.");
        response = latin1.decode(bytes);
      }

      // 4. Parsing del JSON
      final dynamic data = json.decode(response);

      // 5. Gestione Liste vs Oggetti singoli
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map) {
        return [Map<String, dynamic>.from(data)];
      } else {
        print("Formato JSON sconosciuto in $path: ${data.runtimeType}");
        return [];
      }
    } catch (e) {
      print("File non trovato o errore JSON: $path -> $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadClassFiles() async {
    List<String> classFiles = [
      'bardo.json', 'consacrato.json', 'druido.json', 'fuorilegge.json',
      'guardiano.json', 'guerriero.json', 'mago.json', 'ranger.json', 'stregone.json'
    ];
    
    List<Map<String, dynamic>> results = [];
    for (var file in classFiles) {
      String fullPath = 'assets/data/classes/$file';
      var list = await _loadJsonFile(fullPath);
      if (list.isNotEmpty) {
        results.addAll(list);
      }
    }
    return results;
  }
}