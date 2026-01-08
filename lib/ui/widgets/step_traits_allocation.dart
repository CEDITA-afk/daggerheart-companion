import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/creation_provider.dart';

class StepTraitsAllocation extends StatelessWidget {
  const StepTraitsAllocation({super.key});

  @override
  Widget build(BuildContext context) {
    // Mappa: Chiave Interna (Database) -> { Etichetta Visibile, Descrizione }
    // Nota: 'astuzia' nel DB viene mostrata come 'Finezza'
    final Map<String, Map<String, String>> statDefinitions = {
      'agilita': {
        'label': 'Agilità',
        'desc': '(Scatta, salta, manovre)'
      },
      'forza': {
        'label': 'Forza',
        'desc': '(Solleva, fracassa, afferra)'
      },
      'astuzia': { 
        'label': 'Finezza',
        'desc': '(Controlla, nascondi, armeggia)'
      },
      'istinto': {
        'label': 'Istinto',
        'desc': '(Percepisci, fiuta, orientati)'
      },
      'presenza': {
        'label': 'Presenza',
        'desc': '(Affascina, esibisciti, inganna)'
      },
      'conoscenza': {
        'label': 'Conoscenza',
        'desc': '(Ricorda, analizza, comprendi)'
      },
    };
    
    // Standard array da rispettare
    final standardArray = [-1, 0, 0, 1, 1, 2];

    return Consumer<CreationProvider>(
      builder: (context, provider, child) {
        // Calcoliamo quali valori sono stati usati
        List<int> currentValues = provider.tempStats.values.toList();
        List<int> remainingPool = List.from(standardArray);
        
        // Rimuoviamo dal pool i valori già trovati per vedere cosa manca
        for (var val in currentValues) {
          if (remainingPool.contains(val)) {
            remainingPool.remove(val); // Rimuove la prima occorrenza
          }
        }
        
        bool isValid = remainingPool.isEmpty && currentValues.length == 6;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text("ASSEGNA I TRATTI", style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37))),
              const SizedBox(height: 8),
              
              // --- BOX DI RIEPILOGO REGOLE ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isValid ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isValid ? Colors.green : Colors.amber),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Distribuisci i seguenti valori:",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: standardArray.toSet().toList().map((val) {
                        int countRequired = standardArray.where((v) => v == val).length;
                        int countUsed = currentValues.where((v) => v == val).length;
                        
                        bool isComplete = countUsed == countRequired;
                        bool isOver = countUsed > countRequired;
                        
                        Color color = isComplete ? Colors.green : (isOver ? Colors.red : Colors.white);
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: color),
                            borderRadius: BorderRadius.circular(4),
                            color: color.withOpacity(0.2)
                          ),
                          child: Text(
                            "${val > 0 ? '+' : ''}$val ($countUsed/$countRequired)",
                            style: TextStyle(color: color, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              if (provider.validationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.withOpacity(0.2),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(provider.validationError!, style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // --- LISTA INPUT TRATTI ---
              ...statDefinitions.entries.map((entry) {
                String key = entry.key;
                String label = entry.value['label']!;
                String desc = entry.value['desc']!;
                int value = provider.tempStats[key] ?? 0;
                
                return Card(
                  color: const Color(0xFF2C2C2C),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // NOME E DESCRIZIONE
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label.toUpperCase(), 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                              ),
                              Text(
                                desc,
                                style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        
                        // CONTROLLI VALORE
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                              onPressed: () => provider.updateTrait(key, value - 1),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                value > 0 ? "+$value" : "$value",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: value > 0 ? Colors.green : (value < 0 ? Colors.red : Colors.white),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                              onPressed: () => provider.updateTrait(key, value + 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }
    );
  }
}