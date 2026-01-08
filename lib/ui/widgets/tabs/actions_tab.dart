import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../data/models/character.dart';
import '../../../data/data_manager.dart';
import '../dice_roller_dialog.dart';

class ActionsTab extends StatefulWidget {
  final Character character;

  const ActionsTab({super.key, required this.character});

  @override
  State<ActionsTab> createState() => _ActionsTabState();
}

class _ActionsTabState extends State<ActionsTab> {
  // Cache per i dati speciali (Compagno Ranger)
  Map<String, dynamic>? _companionData;
  bool _isLoadingSpecial = false;

  @override
  void initState() {
    super.initState();
    _loadSpecialData();
  }

  /// Carica i dati del Compagno Animale se la classe è Ranger
  Future<void> _loadSpecialData() async {
    // Controllo case-insensitive per l'ID della classe
    if (widget.character.classId.toLowerCase() == 'ranger') {
      setState(() => _isLoadingSpecial = true);
      try {
        // Proviamo a caricare il JSON specifico del compagno
        final jsonString = await rootBundle.loadString('assets/data/classes/ranger_companion.json');
        final data = json.decode(jsonString);
        if (mounted) {
          setState(() {
            _companionData = data;
            _isLoadingSpecial = false;
          });
        }
      } catch (e) {
        print("Errore caricamento Ranger Companion: $e");
        if (mounted) setState(() => _isLoadingSpecial = false);
      }
    }
  }

  void _rollDualityDice(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => DiceRollerDialog(character: widget.character),
    );
  }

  void _rollWeapon(BuildContext context, String weaponName, int attackMod, String damageDice) {
    showDialog(
      context: context,
      builder: (ctx) => DiceRollerDialog(
        character: widget.character,
        initialModifier: attackMod,
        weaponName: weaponName,
        damageDice: damageDice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dhGold = Theme.of(context).primaryColor;
    final char = widget.character;
    final weapons = char.weapons;
    final dm = DataManager();

    // Lista unificata di tutte le capacità
    List<Map<String, dynamic>> allAbilities = [];

    // --- 1. RECUPERO DATI CLASSE ---
    final classData = dm.getClassById(char.classId);
    if (classData != null) {
      // A. PRIVILEGI DI CLASSE (Key: "class_features")
      // I tuoi JSON usano "class_features", aggiungiamo il supporto fallback
      final features = classData['class_features'] ?? classData['features'] ?? classData['core_features'];
      _addFeaturesToList(features, 'CLASSE', dhGold, allAbilities);

      // B. SOTTOCLASSE
      if (char.subclassId != null && classData['subclasses'] != null) {
        final subclasses = classData['subclasses'] as List;
        final sub = subclasses.firstWhere(
          (s) => s['id'] == char.subclassId || s['name'] == char.subclassId, 
          orElse: () => null
        );
        
        if (sub != null) {
          // Descrizione generale sottoclasse
          allAbilities.add({
            'title': sub['name'],
            'desc': sub['description'] ?? sub['text'] ?? 'Abilità della Sottoclasse',
            'source': 'SOTTOCLASSE',
            'color': Colors.purpleAccent
          });
          // Feature specifiche della sottoclasse
          _addFeaturesToList(sub['features'], 'SOTTOCLASSE', Colors.purpleAccent, allAbilities);
        }
      }

      // C. DRUIDO: FORME BESTIALI
      if (char.classId.toLowerCase() == 'druido' && classData['beast_forms'] != null) {
         final forms = classData['beast_forms'] as List;
         // Creiamo una voce speciale per le forme bestiali
         for (var form in forms) {
           String stats = form['stats'] ?? "";
           String traits = (form['traits'] as List?)?.join(", ") ?? "";
           String featureText = "";
           
           if (form['features'] != null) {
             for (var f in form['features']) {
               featureText += "\n• ${f['name']}: ${f['text']}";
             }
           }

           allAbilities.add({
             'title': "Forma: ${form['name']}",
             'desc': "Stats: $stats\nTratti: $traits$featureText",
             'source': 'FORMA BESTIALE (Tier ${form['tier']})',
             'color': Colors.orangeAccent
           });
         }
      }
    }

    // --- 2. RANGER: COMPAGNO ANIMALE ---
    if (_companionData != null) {
       // Aggiungiamo le regole generali del compagno
       final compFeatures = _companionData!['class_features']; // Usa "class_features" anche qui
       _addFeaturesToList(compFeatures, 'COMPAGNO', Colors.green, allAbilities);
    }

    // --- 3. RAZZA (ANCESTRY) ---
    final ancestryData = dm.getAncestryById(char.ancestryId);
    if (ancestryData != null) {
       // Nei tuoi JSON razza la chiave è "features"
       if (ancestryData['features'] != null) {
         _addFeaturesToList(ancestryData['features'], 'RAZZA', Colors.tealAccent, allAbilities);
       } else {
         allAbilities.add({
            'title': ancestryData['name'] ?? 'Tratto Razziale',
            'desc': ancestryData['description'] ?? ancestryData['text'] ?? '',
            'source': 'RAZZA',
            'color': Colors.tealAccent
          });
       }
    }

    // --- 4. COMUNITÀ ---
    final communityData = dm.getCommunityById(char.communityId);
    if (communityData != null) {
       // Nei tuoi JSON comunità la chiave è "features"
       if (communityData['features'] != null) {
         _addFeaturesToList(communityData['features'], 'COMUNITÀ', Colors.lightBlueAccent, allAbilities);
       } else {
         allAbilities.add({
            'title': communityData['name'] ?? 'Tratto Comunità',
            'desc': communityData['description'] ?? communityData['text'] ?? '',
            'source': 'COMUNITÀ',
            'color': Colors.lightBlueAccent
          });
       }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          // --- BOX TIRO RAPIDO ---
          _buildQuickRollSection(context, dhGold),

          const SizedBox(height: 24),

          // --- ARMI ---
          Text("EQUIPAGGIAMENTO ATTIVO", style: GoogleFonts.cinzel(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          if (weapons.isEmpty)
             _buildEmptyState("Nessuna arma equipaggiata")
          else
            _buildWeaponsList(context, weapons, dhGold),

          const SizedBox(height: 24),

          // --- LISTA CAPACITÀ ---
          Text("CAPACITÀ, PRIVILEGI E BONUS", style: GoogleFonts.cinzel(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          
          if (allAbilities.isEmpty)
            const Text("Nessuna abilità attiva trovata.", style: TextStyle(color: Colors.grey))
          else
            ...allAbilities.map((ab) => _buildAbilityCard(ab)),
            
          if (_isLoadingSpecial)
             const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator()))
        ],
      ),
    );
  }

  // --- HELPER METHODS ---

  void _addFeaturesToList(dynamic features, String source, Color color, List<Map<String, dynamic>> list) {
    if (features == null) return;
    if (features is List) {
      for (var f in features) {
        list.add({
          'title': f['name'] ?? 'Abilità',
          'desc': f['text'] ?? f['description'] ?? f['effect'] ?? '', // I JSON usano "text" prevalentemente
          'source': source,
          'color': color
        });
      }
    }
  }

  Widget _buildQuickRollSection(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2438),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.casino, color: color),
              const SizedBox(width: 8),
              Text("TIRO RAPIDO", style: GoogleFonts.cinzel(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _rollDualityDice(context),
              icon: const Icon(Icons.bolt, color: Colors.black),
              label: const Text("LANCIA DADI DUALITÀ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cinzel'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text("Per prove di Caratteristica o tiri generici.", style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildWeaponsList(BuildContext context, List<String> weapons, Color color) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: weapons.length,
      itemBuilder: (context, index) {
        final weaponName = weapons[index];
        return Card(
          color: const Color(0xFF2C2C2C),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.5))),
              child: Icon(Icons.colorize, color: color),
            ),
            title: Text(weaponName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text("Tocca ATTACCA per il danno", style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
              onPressed: () => _rollWeapon(context, weaponName, 0, "d8"), 
              child: const Text("ATTACCA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.white30))),
    );
  }

  Widget _buildAbilityCard(Map<String, dynamic> ability) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, decoration: BoxDecoration(color: ability['color'], borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)))),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (ability['title'] ?? "Abilità").toString().toUpperCase(), 
                            style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (ability['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: (ability['color'] as Color).withOpacity(0.5))
                          ),
                          child: Text(ability['source'], style: TextStyle(color: ability['color'], fontSize: 9, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(ability['desc'], style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}