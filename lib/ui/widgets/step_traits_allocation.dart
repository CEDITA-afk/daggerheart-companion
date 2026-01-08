import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/creation_provider.dart';

class StepTraitsAllocation extends StatelessWidget {
  const StepTraitsAllocation({super.key});

  @override
  Widget build(BuildContext context) {
    // I tratti nel gioco
    final traitsKeys = ['agilita', 'forza', 'astuzia', 'istinto', 'presenza', 'conoscenza'];
    
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
            remainingPool.remove(val); // Rimuove la prima occorrenza trovata
          }
        }
        
        // Se remainingPool è vuoto, la distribuzione è corretta (matematicamente)
        bool isValid = remainingPool.isEmpty && currentValues.length == 6;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text("ASSEGNA I TRATTI", style: TextStyle(fontSize: 24, fontFamily: 'Cinzel', color: Colors.white)),
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
                        // Contiamo quanti ne servono e quanti ne abbiamo messi
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
              
              // --- MESSAGGIO DI ERRORE (Se presente nel provider) ---
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
              ...traitsKeys.map((trait) {
                int value = provider.tempStats[trait] ?? 0;
                
                return Card(
                  color: const Color(0xFF2C2C2C),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trait.toUpperCase(), 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                              onPressed: () => provider.updateTrait(trait, value - 1),
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
                              onPressed: () => provider.updateTrait(trait, value + 1),
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