import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/character_state.dart';

class AttributesStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const AttributesStep({super.key, required this.onNext});

  @override
  ConsumerState<AttributesStep> createState() => _AttributesStepState();
}

class _AttributesStepState extends ConsumerState<AttributesStep> {
  // L'array standard definito dalle regole
  final List<int> _standardArray = [2, 1, 1, 0, 0, -1];
  
  // Mappa temporanea per salvare le scelte dell'utente
  final Map<String, int?> _assignments = {
    'Agility': null,
    'Strength': null,
    'Finesse': null,
    'Instinct': null,
    'Presence': null,
    'Knowledge': null,
  };

  // Descrizioni per aiutare l'utente (dai file Core Rules)
  final Map<String, String> _descriptions = {
    'Agility': 'Sprint, Leap, Maneuver',
    'Strength': 'Lift, Smash, Grapple',
    'Finesse': 'Control, Hide, Tinker',
    'Instinct': 'Perceive, Sense, Navigate',
    'Presence': 'Charm, Perform, Deceive',
    'Knowledge': 'Recall, Analyze, Comprehend',
  };

  @override
  void initState() {
    super.initState();
    // Se lo stato ha già dei valori (es. torno indietro), pre-popoliamoli
    final state = ref.read(characterProvider);
    // Controllo semplice: se sono tutti 0 (default), non li carico, altrimenti sì
    if (state.agility != 0 || state.strength != 0) {
      _assignments['Agility'] = state.agility;
      _assignments['Strength'] = state.strength;
      _assignments['Finesse'] = state.finesse;
      _assignments['Instinct'] = state.instinct;
      _assignments['Presence'] = state.presence;
      _assignments['Knowledge'] = state.knowledge;
    }
  }

  // Calcola quali numeri sono ancora disponibili dall'array
  List<int> _getAvailableValues() {
    final List<int> available = List.from(_standardArray);
    for (var val in _assignments.values) {
      if (val != null) {
        available.remove(val); // Rimuove la prima occorrenza trovata
      }
    }
    return available;
  }

  void _assignValue(String attribute, int value) {
    setState(() {
      // Se questo attributo aveva già un valore, quel valore tornerà disponibile
      _assignments[attribute] = value;
    });
  }
  
  void _clearValue(String attribute) {
    setState(() {
      _assignments[attribute] = null;
    });
  }

  void _confirmSelection() {
    // 1. Salva nel Provider Globale
    ref.read(characterProvider.notifier).setAllAttributes(
      agility: _assignments['Agility'] ?? 0,
      strength: _assignments['Strength'] ?? 0,
      finesse: _assignments['Finesse'] ?? 0,
      instinct: _assignments['Instinct'] ?? 0,
      presence: _assignments['Presence'] ?? 0,
      knowledge: _assignments['Knowledge'] ?? 0,
    );
    
    // 2. Vai avanti
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final available = _getAvailableValues();
    final isComplete = available.isEmpty && !_assignments.containsValue(null);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Assign Attributes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("Standard Array: +2, +1, +1, 0, 0, -1", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),

        // Lista degli Attributi
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _assignments.keys.map((attr) {
              final assignedVal = _assignments[attr];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Icona e Testi
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(attr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(_descriptions[attr]!, style: TextStyle(fontSize: 12, color: Colors.white)),
                          ],
                        ),
                      ),
                      
                      // Selettore
                      assignedVal != null
                          ? Row(
                              children: [
                                Text(
                                  assignedVal >= 0 ? "+$assignedVal" : "$assignedVal",
                                  style: TextStyle(
                                    fontSize: 22, 
                                    fontWeight: FontWeight.bold,
                                    color: assignedVal == 2 ? Colors.amber : (assignedVal < 0 ? Colors.red : Theme.of(context).primaryColor)
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey),
                                  onPressed: () => _clearValue(attr),
                                )
                              ],
                            )
                          : PopupMenuButton<int>(
                              onSelected: (val) => _assignValue(attr, val),
                              itemBuilder: (context) {
                                // Mostra solo i valori unici rimasti per evitare duplicati nel menu
                                final uniqueAvailable = available.toSet().toList()..sort((a, b) => b.compareTo(a));
                                return uniqueAvailable.map((val) {
                                  return PopupMenuItem<int>(
                                    value: val,
                                    child: Text(
                                      val >= 0 ? "+$val" : "$val", 
                                      style: const TextStyle(fontWeight: FontWeight.bold)
                                    ),
                                  );
                                }).toList();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Text("Assign", style: TextStyle(color: Colors.grey)),
                                    Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Mostra i numeri rimanenti in basso
        if (!isComplete)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Pool: ", style: TextStyle(color: Colors.white)),
                ...available.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Chip(
                    label: Text(e >= 0 ? "+$e" : "$e"),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.grey[700],
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                )),
              ],
            ),
          ),

        // Bottone Conferma
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: isComplete ? _confirmSelection : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).primaryColor,
              disabledBackgroundColor: Colors.grey[800],
            ),
            child: const Text("CONFIRM ATTRIBUTES", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}