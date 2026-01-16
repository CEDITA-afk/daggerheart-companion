import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../data/models/character.dart';

class DiceRollerDialog extends StatefulWidget {
  final Character? character;
  final int initialModifier;
  final String? weaponName;
  final String? damageDice;

  const DiceRollerDialog({
    super.key,
    this.character,
    this.initialModifier = 0,
    this.weaponName,
    this.damageDice,
  });

  @override
  State<DiceRollerDialog> createState() => _DiceRollerDialogState();
}

class _DiceRollerDialogState extends State<DiceRollerDialog> {
  // GESTIONE STATO MANUALE (0 = Dualità, 1 = Dado Singolo)
  int _selectedTabIndex = 0;
  
  // STATO DUALITÀ
  int d1 = 1; 
  int d2 = 1; 
  bool isCrit = false;
  bool isHope = false;
  bool isFear = false;
  
  // STATO DADO SINGOLO
  int singleDieResult = 0;
  int selectedDieFaces = 0;

  // STATO CONDIVISO
  int modifier = 0;
  bool hasRolled = false;
  String? resultText;

  // Flag per tracciare il tipo di tiro attivo
  bool _isDualityRoll = false;

  @override
  void initState() {
    super.initState();
    modifier = widget.initialModifier;
    
    // Se è stato richiesto un danno specifico (es. d8), andiamo subito al tab singolo
    if (widget.damageDice != null) {
       _selectedTabIndex = 1; 
    }
  }

  // Cambio Tab Sicuro
  void _switchTab(int index) {
    if (_selectedTabIndex == index) return;
    setState(() {
      _selectedTabIndex = index;
      // Resettiamo il tiro quando cambiamo tab per pulire l'interfaccia
      hasRolled = false;
      resultText = null;
      _isDualityRoll = false;
    });
  }

  // --- LOGICA TIRO DUALITÀ ---
  void _rollDuality() {
    setState(() {
      d1 = Random().nextInt(12) + 1;
      d2 = Random().nextInt(12) + 1;
      hasRolled = true;
      _isDualityRoll = true;
      
      int total = d1 + d2 + modifier;
      
      if (d1 == d2) {
        isCrit = true; isHope = true; isFear = false;
        resultText = "CRITICO! ($total)";
      } else if (d1 > d2) {
        isHope = true; isFear = false; isCrit = false;
        resultText = "Successo con Speranza ($total)";
      } else {
        isFear = true; isHope = false; isCrit = false;
        resultText = "Successo con Paura ($total)";
      }
    });
  }

  // --- LOGICA TIRO SINGOLO ---
  void _rollSingle(int faces) {
    setState(() {
      selectedDieFaces = faces;
      singleDieResult = Random().nextInt(faces) + 1;
      hasRolled = true;
      _isDualityRoll = false; // Importante: indica che non è dualità
      
      int total = singleDieResult + modifier;
      resultText = "Totale: $total";
    });
  }

  @override
  Widget build(BuildContext context) {
    const dhGold = Color(0xFFCFB876);
    const dhSurface = Color(0xFF2A2438);

    return Dialog(
      backgroundColor: dhSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
        side: const BorderSide(color: dhGold, width: 2)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- HEADER ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
            child: Column(
              children: [
                Text(
                  widget.weaponName != null ? "ATTACCO: ${widget.weaponName}" : "DICE ROLLER",
                  style: GoogleFonts.cinzel(color: dhGold, fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // SELETTORE TAB CUSTOM (Sostituisce TabBar)
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: dhGold.withOpacity(0.5))
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildTabButton("DUALITÀ", 0, dhGold)),
                      Expanded(child: _buildTabButton("DADO SINGOLO", 1, dhGold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- CONTENUTO ---
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Modificatori (visibili solo se non ho ancora lanciato)
                  if (!hasRolled) ...[
                     _buildModifiersSection(dhGold),
                     const Divider(color: Colors.white24, height: 30),
                  ],

                  // Mostra il contenuto in base al tab selezionato
                  // Usiamo if/else diretto per evitare che l'altro widget venga costruito
                  if (_selectedTabIndex == 0) 
                    _buildDualityBody()
                  else 
                    _buildSingleBody(dhGold),
                ],
              ),
            ),
          ),
          
          // --- FOOTER ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CHIUDI", style: TextStyle(color: Colors.white54)),
                ),
                if (hasRolled) ...[
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        hasRolled = false;
                        resultText = null;
                        _isDualityRoll = false;
                      });
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("NUOVO TIRO"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: dhGold,
                    ),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  // Pulsante Tab Personalizzato
  Widget _buildTabButton(String label, int index, Color activeColor) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : activeColor,
            fontSize: 12
          ),
        ),
      ),
    );
  }

  // Sezione Modificatori (Chip delle statistiche)
  Widget _buildModifiersSection(Color color) {
    List<Widget> chips = [];
    if (widget.character != null) {
      for (var entry in widget.character!.stats.entries) {
        // Safe cast per evitare null pointer se i dati sono sporchi
        int val = (entry.value as int?) ?? 0;
        String key = entry.key;
        String label = key.length > 3 ? key.substring(0, 3).toUpperCase() : key.toUpperCase();
        
        chips.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilterChip(
            label: Text("$label ${val >= 0 ? '+' : ''}$val"),
            selected: modifier == val,
            onSelected: (_) => setState(() => modifier = val),
            backgroundColor: Colors.black45,
            checkmarkColor: Colors.black,
            selectedColor: color,
            labelStyle: TextStyle(color: modifier == val ? Colors.black : Colors.white, fontSize: 12),
          ),
        ));
      }
    }

    return Column(
      children: [
        if (chips.isNotEmpty) 
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: chips)),
        const SizedBox(height: 12),
        // Controlli Manuali Modificatore
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.grey), onPressed: () => setState(() => modifier--)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(4)),
              child: Text("Mod: ${modifier >= 0 ? '+' : ''}$modifier", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.grey), onPressed: () => setState(() => modifier++)),
          ],
        ),
      ],
    );
  }

  // Corpo Tab Dualità
  Widget _buildDualityBody() {
    // Mostra pulsante se non ho lanciato o se ho lanciato un tipo diverso
    if (!hasRolled || !_isDualityRoll) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.casino, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _rollDuality,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCFB876),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text("LANCIA DUALITÀ", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    // Risultato
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDieVisual(d1, "Speranza", isHope || isCrit ? Colors.blueAccent : Colors.grey, isHope || isCrit),
            const Text("+", style: TextStyle(color: Colors.white24, fontSize: 24)),
            _buildDieVisual(d2, "Paura", isFear ? Colors.redAccent : Colors.grey, isFear),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isCrit ? Colors.purple : (isHope ? Colors.blue : Colors.red)).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: (isCrit ? Colors.purpleAccent : (isHope ? Colors.blueAccent : Colors.redAccent)))
          ),
          child: Column(
            children: [
              Text("TOTALE: ${d1 + d2 + modifier}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(resultText ?? "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        )
      ],
    );
  }

  // Corpo Tab Dado Singolo
  Widget _buildSingleBody(Color accentColor) {
    if (!hasRolled || _isDualityRoll) {
      final dice = [4, 6, 8, 10, 12, 20];
      return Wrap(
        spacing: 16, runSpacing: 16, alignment: WrapAlignment.center,
        children: dice.map((face) => InkWell(
          onTap: () => _rollSingle(face),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 80, height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black38,
              border: Border.all(color: accentColor.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getDieIconWidget(face, accentColor),
                Text("d$face", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        )).toList(),
      );
    }

    return Column(
      children: [
        _buildDieVisual(singleDieResult, "d$selectedDieFaces", accentColor, true),
        const SizedBox(height: 20),
        Text("Totale: ${singleDieResult + modifier}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: accentColor)),
        if (modifier != 0) Text("(Tiro: $singleDieResult ${modifier >= 0 ? '+' : ''} $modifier)", style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDieVisual(int value, String label, Color color, [bool highlight = false]) {
    return Column(
      children: [
        Container(
          width: 64, height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: highlight ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: highlight ? 3 : 1),
            boxShadow: highlight ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)] : []
          ),
          child: Text("$value", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: highlight ? Colors.white : Colors.white54)),
        ),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: highlight ? color : Colors.grey)),
      ],
    );
  }

  // Icona sicura (senza dipendenza da font esterni non caricati)
  Widget _getDieIconWidget(int faces, Color color) {
    IconData icon;
    switch (faces) {
      case 4: icon = Icons.change_history; break;
      case 6: icon = Icons.crop_square; break;
      case 8: icon = Icons.diamond; break;
      case 10: icon = Icons.play_arrow; break;
      case 12: icon = Icons.pentagon; break;
      case 20: icon = Icons.hexagon; break;
      default: icon = Icons.casino;
    }
    return Icon(icon, color: color, size: 32);
  }
}
