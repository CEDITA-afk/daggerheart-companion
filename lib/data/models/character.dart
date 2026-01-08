import '../data_manager.dart'; // Necessario per cercare stats classe/armatura

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

  // --- NUOVI GETTER CALCOLATI (Fix Errori) ---
  
  // 1. Calcolo Evasione: Base Classe + Agilità + Modificatori
  int get evasion {
    int base = 10;
    // Cerca la classe nel DataManager
    final classData = DataManager().getClassById(classId);
    if (classData != null && classData['core_stats'] != null) {
      base = classData['core_stats']['base_evasion'] ?? 10;
    }
    // Agilità
    int agility = stats['agilita'] ?? 0;
    
    return base + agility + evasionModifier;
  }

  // 2. Calcolo Soglie Danno (Parsing dell'Armatura)
  // Se l'armatura ha "Soglie 5/11", major=5, severe=11
  List<int> get _damageThresholds {
    if (armorName.isEmpty) return [1, 2]; // Default senza armatura (molto basso)
    
    // Cerca item stats
    final itemData = DataManager().getItemStats(armorName);
    // Cerca stringa tipo "Soglie 7/15" o nel campo stats
    String statsText = itemData['stats'] ?? "";
    
    // Regex per trovare "X/Y"
    final regex = RegExp(r'(\d+)\/(\d+)');
    final match = regex.firstMatch(statsText);
    
    if (match != null) {
      int major = int.parse(match.group(1)!);
      int severe = int.parse(match.group(2)!);
      return [major, severe];
    }
    
    // Fallback generico basato su Armor Score se non troviamo il testo
    // Daggerheart approssimativo: Major ~ Score*2, Severe ~ Score*4? 
    // Meglio un default sicuro.
    return [armorScore + 2, (armorScore * 2) + 4]; 
  }

  int get majorThreshold => _damageThresholds[0];
  int get severeThreshold => _damageThresholds[1];


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