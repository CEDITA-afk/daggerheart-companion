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
  
  // --- Metodi di Modifica (Logica invariata) ---
  void _modifyStat(String type, int amount) {
    setState(() {
      final char = widget.character;
      switch (type) {
        case 'hope':
          char.hope = (char.hope + amount).clamp(0, 99); // Max arbitrario alto, il foglio ne ha circa 5-6
          break;
        case 'stress':
          char.currentStress = (char.currentStress + amount).clamp(0, char.maxStress);
          break;
        case 'armor':
          int maxSlots = char.maxArmorSlots;
          if (maxSlots == 0) return;
          char.armorSlotsUsed = (char.armorSlotsUsed + amount).clamp(0, maxSlots); 
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

    // Ordine specifico Daggerheart: Agilità, Forza, Finezza, Istinto, Presenza, Conoscenza
    final statOrder = ['agilita', 'forza', 'astuzia', 'istinto', 'presenza', 'conoscenza'];
    final statLabels = {
      'agilita': 'Agilità', 'forza': 'Forza', 'astuzia': 'Finezza',
      'istinto': 'Istinto', 'presenza': 'Presenza', 'conoscenza': 'Conoscenza'
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          // --- 1. Evasione & Armatura (Header Sinistro della scheda) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShieldStat("EVASIONE", "${char.evasion}", dhGold),
              _buildShieldStat("ARMATURA", "${char.armorScore}", Colors.grey),
            ],
          ),
          
          const SizedBox(height: 20),

          // --- 2. Caratteristiche (Riga orizzontale come nel PDF) ---
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: statOrder.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                String key = statOrder[i];
                return _buildAttributeBox(
                  statLabels[key]!,
                  char.stats[key] ?? 0,
                  dhGold
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12),

          // --- 3. Danni & Salute (Sezione Centrale) ---
          Text(
            "DANNI & SALUTE",
            style: GoogleFonts.cinzel(color: dhGold, fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Soglie di Danno (Visivamente simile alla freccia del PDF)
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24)
            ),
            child: Row(
              children: [
                _buildThresholdBox("MINORE", "1 PF", "1-${char.majorThreshold - 1}", Colors.white30),
                const VerticalDivider(color: Colors.white, width: 1),
                _buildThresholdBox("MAGGIORE", "2 PF", "${char.majorThreshold}-${char.severeThreshold - 1}", dhGold.withOpacity(0.5)),
                const VerticalDivider(color: Colors.white, width: 1),
                _buildThresholdBox("SEVERO", "3 PF", "${char.severeThreshold}+", Colors.redAccent.withOpacity(0.5)),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // --- TRACKERS (Pips/Checkbox) ---
          
          // Punti Ferita
          _buildPipTracker(
            "PUNTI FERITA", 
            char.currentHp, 
            char.maxHp, 
            Icons.favorite, 
            Icons.favorite_border,
            Colors.redAccent,
            (val) => _modifyStat('hp', val),
          ),

          const SizedBox(height: 12),

          // Stress
          _buildPipTracker(
            "STRESS", 
            char.currentStress, 
            char.maxStress, 
            Icons.circle, 
            Icons.circle_outlined,
            Colors.purpleAccent,
            (val) => _modifyStat('stress', val),
            isStress: true // Lo stress si riempie al contrario visivamente (o semplicemente si accumula)
          ),

          const SizedBox(height: 12),

          // Armatura (Slot Usati)
          if (char.maxArmorSlots > 0)
            _buildPipTracker(
              "ARMATURA (${char.armorName})", 
              char.armorSlotsUsed, 
              char.maxArmorSlots, 
              Icons.check_box_outline_blank, // Usato = crociato/pieno
              Icons.check_box_outline_blank, // Non usato = vuoto
              Colors.grey,
              (val) => _modifyStat('armor', val),
              isArmor: true
            ),

          const SizedBox(height: 24),
          
          // --- 4. Speranza (Diamonds) ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: dhGold),
              borderRadius: BorderRadius.circular(12),
              color: dhGold.withOpacity(0.05)
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("SPERANZA", style: GoogleFonts.cinzel(color: dhGold, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Text("${char.hope}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Spendi per usare un'esperienza o aiutare un alleato.", style: TextStyle(color: Colors.white54, fontSize: 10, fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.remove), onPressed: () => _modifyStat('hope', -1), color: Colors.white54),
                    // Visualizzazione "Rombi" (Simulata con icone ruotate)
                    Row(
                      children: List.generate(
                        6, // Mostriamo ad esempio 6 slot visivi, o quanti ne ha
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Transform.rotate(
                            angle: 0.785398, // 45 gradi in radianti
                            child: Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(
                                color: index < char.hope ? Colors.white : Colors.transparent,
                                border: Border.all(color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.add), onPressed: () => _modifyStat('hope', 1), color: dhGold),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- WIDGETS PERSONALIZZATI ---

  // 1. Scudo Evasione/Armatura (Simil PDF)
  Widget _buildShieldStat(String label, String value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.shield, size: 70, color: color.withOpacity(0.2)), // Sfondo scudo
            Icon(Icons.shield_outlined, size: 70, color: color), // Bordo scudo
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          color: Colors.black,
          child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  // 2. Box Caratteristica (Verticale)
  Widget _buildAttributeBox(String label, int value, Color color) {
    return Container(
      width: 70,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: color,
            child: Text(label.toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Container(
            width: 36, height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Text(
              value >= 0 ? "+$value" : "$value",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Box Soglie Danno
  Widget _buildThresholdBox(String label, String effect, String range, Color bg) {
    return Expanded(
      child: Container(
        color: bg,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(effect, style: const TextStyle(fontSize: 10, color: Colors.white70)),
            Text(range, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // 4. Tracker a "Punti" (Pips)
  Widget _buildPipTracker(String label, int current, int max, IconData iconFilled, IconData iconEmpty, Color color, Function(int) onChange, {bool isStress = false, bool isArmor = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            Text("$current / $max", style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: max,
            itemBuilder: (context, index) {
              // Logica visualizzazione:
              // HP: index < current è pieno
              // Stress/Armor: index < current è pieno (ma il concetto è che si riempie col danno)
              bool isFilled = index < current;
              
              if (isArmor) {
                 // Per l'armatura usiamo checkbox visive
                 return GestureDetector(
                   onTap: () {
                     // Se clicco su una casella piena, la svuoto (riparo). Se vuota, la riempio (uso).
                     // Logica semplificata: Aggiungi o Rimuovi 1
                     if (isFilled && index == current - 1) onChange(-1); // Rimuovi l'ultimo
                     else if (!isFilled && index == current) onChange(1); // Aggiungi uno
                   },
                   child: Container(
                     margin: const EdgeInsets.only(right: 8),
                     width: 24, height: 24,
                     decoration: BoxDecoration(
                       border: Border.all(color: color),
                       color: isFilled ? color : Colors.transparent,
                     ),
                     child: isFilled ? const Icon(Icons.close, size: 20, color: Colors.black) : null,
                   ),
                 );
              }

              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isFilled ? iconFilled : iconEmpty, 
                  color: isFilled ? color : Colors.grey[800],
                  size: 28,
                ),
                onPressed: () {
                  // Se clicco l'icona 3 (index 2):
                  // Se ho 2 HP -> divento 3.
                  // Se ho 5 HP -> divento 3.
                  int newValue = index + 1;
                  // Se clicco sull'ultimo pieno, lo svuoto (es. vado a index)
                  if (current == newValue) {
                     onChange(-1); // Toglie 1 (più intuitivo step by step)
                  } else if (newValue > current) {
                     onChange(1);
                  } else {
                     // Opzionale: Set diretto (non usato qui per mantenere la logica +/-)
                  }
                },
              );
            },
          ),
        ),
        // Controlli rapidi +/-
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _miniBtn(Icons.remove, () => onChange(-1)),
            const SizedBox(width: 8),
            _miniBtn(Icons.add, () => onChange(1)),
          ],
        )
      ],
    );
  }

  Widget _miniBtn(IconData icon, VoidCallback onTap) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}