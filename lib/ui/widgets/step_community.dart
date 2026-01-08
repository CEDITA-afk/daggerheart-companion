import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/creation_provider.dart';
import '../../data/data_manager.dart';

class StepCommunity extends StatelessWidget {
  const StepCommunity({super.key});

  @override
  Widget build(BuildContext context) {
    // Recupera la lista delle comunit\u00C0
    final communities = DataManager().communities;

    return Consumer<CreationProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SCEGLI LA TUA COMUNIT\u00C0",
                style: TextStyle(fontSize: 20, fontFamily: 'Cinzel', color: Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 8),
              const Text(
                "La comunit\u00C0 definisce il tuo stile di vita e ti conferisce un bonus unico.",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),

              if (communities.isEmpty)
                 const Center(child: Text("Nessuna comunit\u00C0 caricata.", style: TextStyle(color: Colors.red))),

              ...communities.map((community) {
                bool isSelected = false;
                if (provider.tempCommunity != null) {
                   isSelected = provider.tempCommunity!['id'] == community['id'] || 
                                provider.tempCommunity!['name'] == community['name'];
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
                    onTap: () => provider.selectCommunity(community),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                community['name'].toString().toUpperCase(), 
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
                          
                          // DESCRIZIONE
                          Text(
                            community['description'] ?? "Nessuna descrizione.",
                            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4, fontStyle: FontStyle.italic),
                          ),
                          
                          // BONUS COMUNIT\u00C0
                          if (community.containsKey('features') && community['features'] is List) ...[
                            const SizedBox(height: 16),
                            const Text("BONUS COMUNIT\u00C0:", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            ...(community['features'] as List).map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  children: [
                                    TextSpan(text: "${f['name']}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: "${f['description'] ?? f['text'] ?? ''}", style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
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