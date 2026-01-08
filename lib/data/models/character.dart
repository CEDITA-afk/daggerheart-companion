class Character {
  final String id;
  String name;
  String classId;
  String ancestryId; // Assicurati che questo campo esista e sia usato coerentemente
  String communityId; // Idem per questo
  int level;
  Map<String, int> stats; // O 'traits', scegli un nome e usalo ovunque. 'stats' è più comune.
  List<String> inventory;
  List<String> activeCardIds; // Meglio usare gli ID per evitare problemi di serializzazione complessa
  // O List<Map<String, dynamic>> activeCards se preferisci salvare l'oggetto intero

  // Statistiche vitali (non finali perché modificabili)
  int currentHp;
  int maxHp;
  int currentStress;
  int maxStress;
  int armorScore;
  int armorSlotsUsed;
  int hope;
  int gold;
  int evasionModifier;

  // Campi opzionali
  String? subclassId;
  String? background;
  String? pronouns;
  String? description;
  String armorName;
  List<String> weapons;
  List<String> experiences;
  Map<String, String>? narrativeAnswers; // Per background e legami
  Map<String, dynamic>? companion; // Per Ranger

  // Getter di compatibilità (se hai codice vecchio che usa questi nomi)
  Map<String, int> get traits => stats;
  Map<String, String>? get bonds => narrativeAnswers;
  Map<String, String>? get backgroundAnswers => narrativeAnswers;


  Character({
    required this.id,
    required this.name,
    required this.classId,
    required this.ancestryId,
    required this.communityId,
    required this.level,
    required this.stats,
    required this.inventory,
    required this.activeCardIds, // O activeCards
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
      activeCardIds: List<String>.from(json['activeCardIds'] ?? []), // O gestione activeCards
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