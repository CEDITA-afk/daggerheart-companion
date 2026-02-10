/// Questo file contiene i suggerimenti ufficiali dal manuale "Character Guides".
/// Poiché questi dati non sono nei JSON, li mappiamo qui staticamente.

class ClassGuide {
  final Map<String, int> stats; // Agility, Strength, etc.
  final String primaryWeapon; // Nome dell'arma (es. "Rapier")
  final String? secondaryWeapon; // Nome dell'arma secondaria (null se 2-mani)
  final String armor; // Nome dell'armatura
  final List<String> inventoryChoices; // Pozioni o oggetti di classe
  final List<String> backgroundQuestions;
  final List<String> connections;

  const ClassGuide({
    required this.stats,
    required this.primaryWeapon,
    this.secondaryWeapon,
    required this.armor,
    required this.inventoryChoices,
    required this.backgroundQuestions,
    required this.connections,
  });
}

final Map<String, ClassGuide> classDefaults = {
  "BARD": ClassGuide(
    stats: {'Agility': 0, 'Strength': -1, 'Finesse': 1, 'Instinct': 0, 'Presence': 2, 'Knowledge': 1},
    primaryWeapon: "Rapier",
    secondaryWeapon: "Small Dagger",
    armor: "Gambeson Armor",
    inventoryChoices: ["Minor Health Potion OR Minor Stamina Potion", "A romance novel OR A letter never opened"],
    backgroundQuestions: [
      "Who from your community taught you to have such confidence in yourself?",
      "You were in love once. Who did you adore, and how did they hurt you?",
      "You've always looked up to another bard. Who are they, and why do you idolize them?"
    ],
    connections: [
      "What made you realize we were going to be such good friends?",
      "What do I do that annoys you?",
      "Why do you grab my hand at night?"
    ],
  ),
  "DRUID": ClassGuide(
    stats: {'Agility': 1, 'Strength': 0, 'Finesse': 1, 'Instinct': 2, 'Presence': -1, 'Knowledge': 0},
    primaryWeapon: "Shortstaff",
    secondaryWeapon: "Round Shield",
    armor: "Leather Armor",
    inventoryChoices: ["Minor Health Potion OR Minor Stamina Potion", "A small bag of rocks and bones OR A strange pendant"],
    backgroundQuestions: [
      "Why was the community you grew up in so reliant on nature and its creatures?",
      "Who was the first wild animal you bonded with? Why did your bond end?",
      "Who has been trying to hunt you down? What do they want from you?"
    ],
    connections: [
      "What did you confide in me that makes me leap into danger for you every time?",
      "What animal do I say you remind me of?",
      "What affectionate nickname have you given me?"
    ],
  ),
  "GUARDIAN": ClassGuide(
    stats: {'Agility': 1, 'Strength': 2, 'Finesse': -1, 'Instinct': 0, 'Presence': 1, 'Knowledge': 0},
    primaryWeapon: "Battleaxe",
    secondaryWeapon: null, // Two-Handed
    armor: "Chainmail Armor",
    inventoryChoices: ["Minor Health Potion OR Minor Stamina Potion", "A totem from your mentor OR A secret key"],
    backgroundQuestions: [
      "Who from your community did you fail to protect, and why do you still think of them?",
      "You've been tasked with protecting something important. What is it?",
      "You consider an aspect of yourself to be a weakness. What is it?"
    ],
    connections: [
      "How did I save your life the first time we met?",
      "What small gift did you give me that you notice I always carry with me?",
      "What lie have you told me about yourself that I absolutely believe?"
    ],
  ),
  "RANGER": ClassGuide(
    stats: {'Agility': 2, 'Strength': 0, 'Finesse': 1, 'Instinct': 1, 'Presence': -1, 'Knowledge': 0},
    primaryWeapon: "Shortbow",
    secondaryWeapon: null, // Two-Handed
    armor: "Leather Armor",
    inventoryChoices: ["Minor Health Potion OR Minor Stamina Potion", "A trophy from your first kill OR A broken compass"],
    backgroundQuestions: [
      "A terrible creature hurt your community, and you've vowed to hunt them down. What are they?",
      "Your first kill almost killed you, too. What was it?",
      "You've traveled many dangerous lands, but what is the one place you refuse to go?"
    ],
    connections: [
      "What friendly competition do we have?",
      "Why do you act differently when we're alone than when others are around?",
      "What threat have you asked me to watch for, and why are you worried about it?"
    ],
  ),
  "ROGUE": ClassGuide(
    stats: {'Agility': 1, 'Strength': -1, 'Finesse': 2, 'Instinct': 0, 'Presence': 1, 'Knowledge': 0},
    primaryWeapon: "Dagger",
    secondaryWeapon: "Small Dagger",
    armor: "Gambeson Armor",
    inventoryChoices: ["Minor Health Potion OR Minor Stamina Potion", "A set of forgery tools OR A grappling hook"],
    backgroundQuestions: [
      "What did you get caught doing that got you exiled from your home community?",
      "You used to have a different life. Who from your past is still chasing you?",
      "Who from your past were you most sad to say goodbye to?"
    ],
    connections: [
      "What did I recently convince you to do that got us both in trouble?",
      "What have I discovered about your past that I hold secret from the others?",
      "Who do you know from my past, and how have they influenced your feelings about me?"
    ],
  ),
  "SERAPH": ClassGuide(
    stats: {'Agility': 0, 'Strength': 2, 'Finesse': 0, 'Instinct': 1, 'Presence': 1, 'Knowledge': -1},
    primaryWeapon: "Hallowed Axe",
    secondaryWeapon: "Round Shield",
    armor: "Chainmail Armor",
    inventoryChoices: ["Minor Health Potion OR Minor Stamina Potion", "A bundle of offerings OR A sigil of your god"],
    backgroundQuestions: [
      "Which god did you devote yourself to? What incredible feat did they perform for you?",
      "How did your appearance change after taking your oath?",
      "In what strange or unique way do you communicate with your god?"
    ],
    connections: [
      "What promise did you make me agree to, should you die on the battlefield?",
      "Why do you ask me so many questions about my god?",
      "You've told me to protect one member of our party above all others. Who are they?"
    ],
  ),
  "SORCERER": ClassGuide(
    stats: {'Agility': 0, 'Strength': -1, 'Finesse': 1, 'Instinct': 2, 'Presence': 1, 'Knowledge': 0},
    primaryWeapon: "Dualstaff",
    secondaryWeapon: null, // Two-Handed
    armor: "Gambeson Armor",
    inventoryChoices: ["Minor Health Potion OR Minor Stamina Potion", "A whispering orb OR A family heirloom"],
    backgroundQuestions: [
      "What did you do that made the people in your community wary of you?",
      "What mentor taught you to control your untamed magic, and why are they gone?",
      "You have a deep fear you hide from everyone. What is it?"
    ],
    connections: [
      "Why do you trust me so deeply?",
      "What did I do that makes you cautious around me?",
      "Why do we keep our shared past a secret?"
    ],
  ),
  "WARRIOR": ClassGuide(
    stats: {'Agility': 2, 'Strength': 1, 'Finesse': 0, 'Instinct': 1, 'Presence': -1, 'Knowledge': 0},
    primaryWeapon: "Longsword",
    secondaryWeapon: null, // Two-Handed
    armor: "Chainmail Armor",
    inventoryChoices: ["Minor Health Potion OR Minor Stamina Potion", "The drawing of a lover OR A sharpening stone"],
    backgroundQuestions: [
      "Who taught you to fight, and why did they stay behind when you left home?",
      "Somebody defeated you in battle years ago and left you to die. Who was it?",
      "What legendary place have you always wanted to visit?"
    ],
    connections: [
      "We knew each other long before this party came together. How?",
      "What mundane task do you usually help me with off the battlefield?",
      "What fear am I helping you overcome?"
    ],
  ),
  "WIZARD": ClassGuide(
    stats: {'Agility': -1, 'Strength': 0, 'Finesse': 0, 'Instinct': 1, 'Presence': 1, 'Knowledge': 2},
    primaryWeapon: "Greatstaff",
    secondaryWeapon: null, // Two-Handed
    armor: "Leather Armor",
    inventoryChoices: ["Minor Health Potion OR Minor Stamina Potion", "A book you're translating OR A tiny elemental pet"],
    backgroundQuestions: [
      "What responsibilities did your community once count on you for? How did you let them down?",
      "You've spent your life searching for a book or object. What is it?",
      "You have a powerful rival. Who are they?"
    ],
    connections: [
      "What favor have I asked of you that you're not sure you can fulfill?",
      "What weird hobby or strange fascination do we both share?",
      "What secret about yourself have you entrusted only to me?"
    ],
  ),
};