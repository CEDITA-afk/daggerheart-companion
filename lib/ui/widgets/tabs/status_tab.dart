import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/character.dart';

class StatusTab extends StatefulWidget {
  final Character character;

  const StatusTab({super.key, required this.character});

  @override
  State<StatusTab> createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  
  // --- Metodi di Modifica ---
  void _modifyStat(String type, int amount) {
    setState(() {
      final char = widget.character;
      switch (type) {
        case 'hope':
          char.hope = (char.hope + amount).clamp(0, 6);
          break;
        case 'stress':
          char.currentStress = (char.currentStress + amount).clamp(0, char.maxStress);
          break;
        case 'armor':
          // Gli slot usati non possono scendere sotto 0 o superare un limite ragionevole (es. 6 o 10)
          char.armorSlotsUsed = (char.armorSlotsUsed + amount).clamp(0, 10); 
          break;
        case 'hp':
          char.currentHp = (char.currentHp + amount).clamp(0, char.maxHp);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final char = widget.character;
    final dhGold = Theme.of(context).primaryColor;

    // DEFINIZIONE CENTRALIZZATA DEI NOMI E DESCRIZIONI
    final Map<String, Map<String, String>> statDefinitions = {
      'agilita': {'label': 'Agilità', 'desc': '(Scatta, salta, manovre)'},
      'forza': {'label': 'Forza', 'desc': '(Solleva, fracassa, afferra)'},
      'astuzia': {'label': 'Finezza', 'desc': '(Controlla, nascondi, armeggia)'},
      'istinto': {'label': 'Istinto', 'desc': '(Percepisci, fiuta, orientati)'},
      'presenza': {'label': 'Presenza', 'desc': '(Affascina, esibisciti, inganna)'},
      'conoscenza': {'label': 'Conoscenza', 'desc': '(Ricorda, analizza, comprendi)'},
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- HEADER STATS ---
          Text(
            "TRATTI & CARATTERISTICHE",
            style: GoogleFonts.cinzel(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // --- GRIGLIA STATISTICHE ---
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: statDefinitions.entries.map((entry) {
              final key = entry.key;
              final label = entry.value['label']!;
              final desc = entry.value['desc']!;
              final value = char.stats[key] ?? 0;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2438),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dhGold.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.toUpperCase(),
                            style: GoogleFonts.cinzel(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: dhGold
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            desc,
                            style: const TextStyle(
                              fontSize: 10, 
                              color: Colors.grey, 
                              fontStyle: FontStyle.italic
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black38,
                        border: Border.all(color: dhGold),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        value >= 0 ? "+$value" : "$value",
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          
          // --- SEZIONE: RISORSE VITALI (INTERATTIVA) ---
          Text(
            "RISORSE VITALI",
            style: GoogleFonts.cinzel(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // PUNTI FERITA (HP)
          _buildInteractiveCard(
            title: "PUNTI FERITA",
            value: "${char.currentHp} / ${char.maxHp}",
            icon: Icons.favorite,
            color: Colors.redAccent,
            dhGold: dhGold,
            onRemove: () => _modifyStat('hp', -1),
            onAdd: () => _modifyStat('hp', 1),
            progress: char.maxHp > 0 ? char.currentHp / char.maxHp : 0,
          ),
          const SizedBox(height: 12),

          // RIGA: SPERANZA E STRESS
          Row(
            children: [
              Expanded(
                child: _buildInteractiveCard(
                  title: "SPERANZA",
                  value: "${char.hope}",
                  icon: Icons.star,
                  color: Colors.amber,
                  dhGold: dhGold,
                  onRemove: () => _modifyStat('hope', -1),
                  onAdd: () => _modifyStat('hope', 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInteractiveCard(
                  title: "STRESS",
                  value: "${char.currentStress} / ${char.maxStress}",
                  icon: Icons.psychology,
                  color: Colors.purpleAccent,
                  dhGold: dhGold,
                  onRemove: () => _modifyStat('stress', -1),
                  onAdd: () => _modifyStat('stress', 1),
                  progress: char.maxStress > 0 ? char.currentStress / char.maxStress : 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ARMATURA
          _buildInteractiveCard(
            title: "ARMATURA",
            value: "${char.armorScore}",
            subValue: "Slot Usati: ${char.armorSlotsUsed}",
            icon: Icons.shield,
            color: Colors.grey,
            dhGold: dhGold,
            // Qui i bottoni controllano gli SLOT usati, non il punteggio (che è fisso)
            onRemove: () => _modifyStat('armor', -1), // Ripara armatura (meno slot usati)
            onAdd: () => _modifyStat('armor', 1),     // Usa armatura (più slot usati)
            customBtnLabels: ['RIPARA', 'USA'],       // Etichette personalizzate per chiarezza
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          // --- STATISTICHE DERIVATE ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDerivedStat("EVASIONE", char.evasion, dhGold),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildDerivedStat("SOGLIA MAGG.", char.majorThreshold, Colors.orange),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildDerivedStat("SOGLIA GRAVE", char.severeThreshold, Colors.red),
            ],
          ),
          const SizedBox(height: 80), // Spazio finale per FAB
        ],
      ),
    );
  }

  // Widget Card Interattiva con bottoni +/-
  Widget _buildInteractiveCard({
    required String title, 
    required String value, 
    String? subValue,
    required IconData icon, 
    required Color color, 
    required Color dhGold,
    required VoidCallback onRemove,
    required VoidCallback onAdd,
    List<String>? customBtnLabels, // Opzionale: cambia testo bottoni (es. - / +)
    double? progress
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dhGold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header Icona + Titolo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          
          // Valore Principale
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          if (subValue != null)
            Text(subValue, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          
          // Barra Progresso (Opzionale)
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.black,
                color: color,
                minHeight: 6,
              ),
            )
          ],

          const SizedBox(height: 12),

          // Bottoni Azione
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallButton(
                icon: Icons.remove, 
                label: customBtnLabels?[0], 
                color: Colors.red.withOpacity(0.8), 
                onTap: onRemove
              ),
              _buildSmallButton(
                icon: Icons.add, 
                label: customBtnLabels?[1], 
                color: Colors.green.withOpacity(0.8), 
                onTap: onAdd
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallButton({IconData? icon, String? label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: label != null 
          ? Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))
          : Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _buildDerivedStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          "$value",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}