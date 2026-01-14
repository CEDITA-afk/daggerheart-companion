import '../data_manager.dart';

class Character {
  final String id;
  String name;
  String classId;
  String ancestryId;
  String communityId;
  int level;
  Map<String, int> stats;
  List<String> inventory;
  List<String> activeCardIds;

  int currentHp;
  int maxHp;
  int currentStress;
  int maxStress;
  int armorScore;
  int armorSlotsUsed;
  int hope;
  int gold;
  int evasionModifier;

  String? subclassId;
  String? background;
  String? pronouns;
  String? description;
  String armorName;
  List<String> weapons;
  List<String> experiences;
  Map<String, String>? narrativeAnswers;
  Map<String, dynamic>? companion;

  // Getter di compatibilità
  Map<String, int> get traits => stats;
  Map<String, String>? get bonds => narrativeAnswers;
  Map<String, String>? get backgroundAnswers => narrativeAnswers;

  // --- GETTER CALCOLATI ---
  
  // 1. Evasione: Base Classe + Agilità + Modificatori
  int get evasion {
    int base = 10;
    final classData = DataManager().getClassById(classId);
    if (classData != null && classData['core_stats'] != null) {
      base = classData['core_stats']['base_evasion'] ?? 10;
    }
    int agility = stats['agilita'] ?? 0;
    return base + agility + evasionModifier;
  }

  // 2. Soglie Danno
  List<int> get _damageThresholds {
    if (armorName.isEmpty) return [1, 2]; // Valori base minimi
    
    final itemData = DataManager().getItemStats(armorName);
    String statsText = itemData['stats'] ?? "";
    
    // Cerca pattern "5/10" nel testo
    final regex = RegExp(r'(\d+)\/(\d+)');
    final match = regex.firstMatch(statsText);
    
    if (match != null) {
      int major = int.parse(match.group(1)!);
      int severe = int.parse(match.group(2)!);
      return [major, severe];
    }
    // Fallback se non trova il testo esplicito
    return [armorScore + 2, (armorScore * 2) + 4]; 
  }

  int get majorThreshold => _damageThresholds[0];
  int get severeThreshold => _damageThresholds[1];

  // 3. Slot Armatura (IL FIX PER L'ERRORE DI COMPILAZIONE)
  int get maxArmorSlots {
    if (armorName.isEmpty) return 0; 
    
    // Recupera dati dal DataManager
    final itemData = DataManager().getItemStats(armorName);
    
    // Se il JSON ha una chiave 'slots', usala
    if (itemData.containsKey('slots')) {
      return int.tryParse(itemData['slots'].toString()) ?? 3;
    }
    
    // Default Daggerheart per la maggior parte delle armature
    return 3; 
  }

  Character({
    required this.id,
    required this.name,
    required this.classId,
    required this.ancestryId,
    required this.communityId,
    required this.level,
    required this.stats,
    required this.inventory,
    required this.activeCardIds,
    this.currentHp = 6,
    this.maxHp = 6,
    this.currentStress = 0,
    this.maxStress = 5,
    this.armorScore = 0,
    this.armorSlotsUsed = 0,
    this.hope = 2,
    this.gold = 0,
    this.evasionModifier = 0,
    this.subclassId,
    this.background,
    this.pronouns,
    this.description,
    this.armorName = "",
    this.weapons = const [],
    this.experiences = const [],
    this.narrativeAnswers,
    this.companion,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sconosciuto',
      classId: json['classId'] ?? '',
      ancestryId: json['ancestryId'] ?? '',
      communityId: json['communityId'] ?? '',
      level: json['level'] ?? 1,
      stats: Map<String, int>.from(json['stats'] ?? {}),
      inventory: List<String>.from(json['inventory'] ?? []),
      activeCardIds: List<String>.from(json['activeCardIds'] ?? []),
      currentHp: json['currentHp'] ?? 6,
      maxHp: json['maxHp'] ?? 6,
      currentStress: json['currentStress'] ?? 0,
      maxStress: json['maxStress'] ?? 5,
      armorScore: json['armorScore'] ?? 0,
      armorSlotsUsed: json['armorSlotsUsed'] ?? 0,
      hope: json['hope'] ?? 2,
      gold: json['gold'] ?? 0,
      evasionModifier: json['evasionModifier'] ?? 0,
      subclassId: json['subclassId'],
      background: json['background'],
      pronouns: json['pronouns'],
      description: json['description'],
      armorName: json['armorName'] ?? '',
      weapons: List<String>.from(json['weapons'] ?? []),
      experiences: List<String>.from(json['experiences'] ?? []),
      narrativeAnswers: json['narrativeAnswers'] != null ? Map<String, String>.from(json['narrativeAnswers']) : null,
      companion: json['companion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'classId': classId,
      'ancestryId': ancestryId,
      'communityId': communityId,
      'level': level,
      'stats': stats,
      'inventory': inventory,
      'activeCardIds': activeCardIds,
      'currentHp': currentHp,
      'maxHp': maxHp,
      'currentStress': currentStress,
      'maxStress': maxStress,
      'armorScore': armorScore,
      'armorSlotsUsed': armorSlotsUsed,
      'hope': hope,
      'gold': gold,
      'evasionModifier': evasionModifier,
      'subclassId': subclassId,
      'background': background,
      'pronouns': pronouns,
      'description': description,
      'armorName': armorName,
      'weapons': weapons,
      'experiences': experiences,
      'narrativeAnswers': narrativeAnswers,
      'companion': companion,
    };
  }
}