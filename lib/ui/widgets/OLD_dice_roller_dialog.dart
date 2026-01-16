import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../data/models/character.dart';

class DiceRollerDialog extends StatefulWidget {
  final Character? character;
  final int initialModifier;
  final String? weaponName;
  final String? damageDice; // Es. "d8" o "2d6" (per ora supportiamo dadi singoli)

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

class _DiceRollerDialogState extends State<DiceRollerDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // DUALITY STATE
  int d1 = 1;
  int d2 = 1;
  bool isCrit = false;
  bool isHope = false;
  bool isFear = false;
  
  // SINGLE DIE STATE
  int? singleDieResult;
  int? selectedDieFaces;

  // SHARED STATE
  int modifier = 0;
  bool hasRolled = false;
  String? resultText;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    modifier = widget.initialModifier;
    
    // Se c'è un dado danno specificato (es. attacco arma), prova a parsarlo
    if (widget.damageDice != null) {
      // Logica semplificata: se contiene "d8", vai al tab singoli
       if (widget.weaponName != null) {
          // Se è un'arma, spesso si tira prima dualità (TXC) poi danno. 
          // Lasciamo default Dualità, ma l'utente può cambiare.
       }
    }
    
    // Reset stato al cambio tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          hasRolled = false;
          resultText = null;
          singleDieResult = null;
          // Non resettiamo il modificatore, potrebbe servire
        });
      }
    });
  }

  // --- LOGICA TIRO DUALITÀ ---
  void _rollDuality() {
    setState(() {
      d1 = Random().nextInt(12) + 1;
      d2 = Random().nextInt(12) + 1;
      hasRolled = true;

      int total = d1 + d2 + modifier;
      
      if (d1 == d2) {
        isCrit = true;
        isHope = true; 
        isFear = false;
        resultText = "CRITICO! ($total)";
      } else if (d1 > d2) {
        isHope = true;
        isFear = false;
        isCrit = false;
        resultText = "Successo con Speranza ($total)";
      } else {
        isFear = true;
        isHope = false;
        isCrit = false;
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
      int total = singleDieResult! + modifier;
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
          // --- HEADER & TABS ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              children: [
                Text(
                  widget.weaponName != null ? "ATTACCO: ${widget.weaponName}" : "DICE ROLLER",
                  style: GoogleFonts.cinzel(color: dhGold, fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: dhGold.withOpacity(0.5))
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: dhGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: dhGold,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: "DUALITÀ"),
                      Tab(text: "DADO SINGOLO"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- CONTENUTO (SCROLLABLE) ---
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // MODIFICATORI (COMUNE)
                  if (!hasRolled) ...[
                     _buildModifiersSection(),
                     const Divider(color: Colors.white24, height: 30),
                  ],

                  // BODY DEL TAB CORRENTE
                  SizedBox(
                    height: 220, // Altezza fissa per l'area dadi
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(), // Evita scroll orizzontale
                      children: [
                        _buildDualityTab(),
                        _buildSingleTab(dhGold),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // --- FOOTER AZIONI ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CHIUDI", style: TextStyle(color: Colors.white54)),
                ),
                if (hasRolled)
                  const SizedBox(width: 16),
                if (hasRolled)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        hasRolled = false;
                        resultText = null;
                        singleDieResult = null;
                      });
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("NUOVO TIRO"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: dhGold,
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildModifiersSection() {
    return Column(
      children: [
        if (widget.character != null)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.character!.stats.entries.map((entry) {
                String label = entry.key.substring(0, 3).toUpperCase();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text("$label ${entry.value >= 0 ? '+' : ''}${entry.value}"),
                    selected: modifier == entry.value,
                    onSelected: (bool selected) {
                      setState(() => modifier = entry.value);
                    },
                    backgroundColor: Colors.black45,
                    checkmarkColor: Colors.black,
                    selectedColor: const Color(0xFFCFB876),
                    labelStyle: TextStyle(
                      color: modifier == entry.value ? Colors.black : Colors.white, 
                      fontSize: 12
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
              onPressed: () => setState(() => modifier--),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(4)),
              child: Text("Mod: ${modifier >= 0 ? '+' : ''}$modifier", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
              onPressed: () => setState(() => modifier++),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDualityTab() {
    if (!hasRolled) {
      return Center(
        child: ElevatedButton(
          onPressed: _rollDuality,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCFB876),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cinzel'),
          ),
          child: const Text("LANCIA DUALITÀ"),
        ),
      );
    }

    // Risultato Dualità
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDieVisual(d1, "Speranza", isHope || isCrit ? Colors.blue : Colors.grey),
            const Text("+", style: TextStyle(color: Colors.white24, fontSize: 24)),
            _buildDieVisual(d2, "Paura", isFear ? Colors.red : Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isCrit ? Colors.purple.withOpacity(0.2) : (isHope ? Colors.blue.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isCrit ? Colors.purpleAccent : (isHope ? Colors.blueAccent : Colors.redAccent))
          ),
          child: Column(
            children: [
              Text(
                "${d1 + d2 + modifier}",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                resultText ?? "",
                style: TextStyle(
                  color: isCrit ? Colors.purpleAccent : (isHope ? Colors.blueAccent : Colors.redAccent),
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSingleTab(Color accentColor) {
    // Lista dadi disponibili
    final dice = [4, 6, 8, 10, 12, 20];

    if (!hasRolled) {
      return GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: dice.map((face) {
          return InkWell(
            onTap: () => _rollSingle(face),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                border: Border.all(color: accentColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getDieIcon(face), color: accentColor, size: 24),
                  Text("d$face", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    // Risultato Singolo
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDieVisual(singleDieResult!, "d$selectedDieFaces", accentColor),
          const SizedBox(height: 20),
          Text(
            "Totale: ${singleDieResult! + modifier}",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: accentColor),
          ),
          if (modifier != 0)
            Text("(Tiro: $singleDieResult ${modifier >= 0 ? '+' : ''} $modifier)", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDieVisual(int value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)]
          ),
          child: Center(
            child: Text(
              "$value",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
      ],
    );
  }

  IconData _getDieIcon(int faces) {
    // Usiamo icone approssimative dato che Material non ha tutti i poliedri
    switch (faces) {
      case 4: return Icons.change_history; // Triangolo
      case 6: return Icons.crop_square;    // Quadrato
      case 8: return Icons.diamond;        // Rombo (simile ottaedro)
      case 10: return Icons.play_arrow;    // Aquilone (approx)
      case 12: return Icons.pentagon;      // Pentagono (dodecaedro facce)
      case 20: return Icons.hexagon;       // Esagono (icosaedro profilo)
      default: return Icons.casino;
    }
  }
}
