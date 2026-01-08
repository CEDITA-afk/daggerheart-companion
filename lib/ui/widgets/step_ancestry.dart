import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/creation_provider.dart';
import '../../data/data_manager.dart';

class StepAncestry extends StatelessWidget {
  const StepAncestry({super.key});

  @override
  Widget build(BuildContext context) {
    // Recupera la lista dei retaggi dal DataManager
    final ancestries = DataManager().races; 

    return Consumer<CreationProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SCEGLI IL TUO RETAGGIO",
                style: TextStyle(fontSize: 20, fontFamily: 'Cinzel', color: Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Il retaggio determina il tuo aspetto e le tue abilit\u00C0 innate.",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),

              if (ancestries.isEmpty)
                 const Center(child: Text("Nessun retaggio caricato.", style: TextStyle(color: Colors.red))),

              ...ancestries.map((ancestry) {
                // Controlla se è selezionato
                bool isSelected = false;
                if (provider.tempAncestry != null) {
                   isSelected = provider.tempAncestry!['id'] == ancestry['id'] || 
                                provider.tempAncestry!['name'] == ancestry['name'];
                }

                return Card(
                  color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.15) : const Color(0xFF2C2C2C),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                      width: 2
                    ),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: InkWell(
                    onTap: () => provider.selectAncestry(ancestry),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TESTATA: NOME E CHECKBOX
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ancestry['name'].toString().toUpperCase(), 
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 18,
                                  fontFamily: 'Cinzel'
                                )
                              ),
                              if (isSelected) 
                                const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 28),
                            ],
                          ),
                          const Divider(color: Colors.white24, height: 24),
                          
                          // DESCRIZIONE COMPLETA
                          Text(
                            ancestry['description'] ?? "Nessuna descrizione.",
                            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                          ),
                          
                          // SEZIONE FEATURES (CAPACIT\u00C0)
                          // Cerchiamo se ci sono 'features' o 'abilities' nel JSON
                          if (ancestry.containsKey('features') && ancestry['features'] is List) ...[
                            const SizedBox(height: 16),
                            const Text("CAPACIT\u00C0 DI RETAGGIO:", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            ...(ancestry['features'] as List).map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(color: Color(0xFFD4AF37))),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.white, fontSize: 13),
                                        children: [
                                          TextSpan(text: "${f['name']}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${f['description'] ?? f['text'] ?? ''}", style: const TextStyle(color: Colors.white70)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}