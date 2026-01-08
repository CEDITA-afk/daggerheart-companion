import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/character.dart';
import '../../../data/data_manager.dart'; 
import '../dice_roller_dialog.dart';

class ActionsTab extends StatelessWidget {
  final Character character;

  const ActionsTab({super.key, required this.character});

  void _rollDualityDice(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => DiceRollerDialog(
        character: character,
      ),
    );
  }

  void _rollWeapon(BuildContext context, String weaponName, int attackMod, String damageDice) {
    showDialog(
      context: context,
      builder: (ctx) => DiceRollerDialog(
        character: character,
        initialModifier: attackMod,
        weaponName: weaponName,
        damageDice: damageDice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dhGold = Theme.of(context).primaryColor;
    final weapons = character.weapons;
    final dm = DataManager();

    // --- 1. AGGREGAZIONE DI TUTTE LE ABILITÀ ---
    List<Map<String, dynamic>> allAbilities = [];

    // A. CLASSE
    final classData = dm.getClassById(character.classId);
    if (classData != null) {
      final features = classData['features'] ?? classData['core_features'];
      if (features != null && features is List) {
        for (var f in features) {
          allAbilities.add({
            'title': f['name'] ?? 'Abilità Classe',
            'desc': f['description'] ?? f['text'] ?? '',
            'source': 'CLASSE',
            'color': dhGold
          });
        }
      }

      // Sottoclasse
      if (character.subclassId != null && classData['subclasses'] != null) {
        final subclasses = classData['subclasses'] as List;
        final sub = subclasses.firstWhere(
          (s) => s['id'] == character.subclassId || s['name'] == character.subclassId, 
          orElse: () => null
        );
        if (sub != null) {
          allAbilities.add({
            'title': sub['name'],
            'desc': sub['description'] ?? sub['text'] ?? 'Abilità della Sottoclasse',
            'source': 'SOTTOCLASSE',
            'color': Colors.purpleAccent
          });
           // Feature extra sottoclasse
          if (sub['features'] != null && sub['features'] is List) {
            for (var f in sub['features']) {
              allAbilities.add({
                'title': f['name'],
                'desc': f['description'] ?? f['text'] ?? '',
                'source': 'SOTTOCLASSE',
                'color': Colors.purpleAccent
              });
            }
          }
        }
      }
    }

    // B. RAZZA (ANCESTRY)
    final ancestryData = dm.getAncestryById(character.ancestryId);
    if (ancestryData != null) {
       // A volte è una lista 'features', a volte l'oggetto stesso ha 'description'
       if (ancestryData['features'] != null && ancestryData['features'] is List) {
         for (var f in ancestryData['features']) {
            allAbilities.add({
              'title': f['name'] ?? ancestryData['name'],
              'desc': f['description'] ?? f['text'] ?? '',
              'source': 'RAZZA',
              'color': Colors.greenAccent
            });
         }
       } else if (ancestryData['description'] != null || ancestryData['text'] != null) {
          // Fallback se la razza ha una descrizione diretta
           allAbilities.add({
              'title': ancestryData['name'] ?? 'Tratto Razziale',
              'desc': ancestryData['description'] ?? ancestryData['text'] ?? '',
              'source': 'RAZZA',
              'color': Colors.greenAccent
            });
       }
    }

    // C. COMUNITÀ
    final communityData = dm.getCommunityById(character.communityId);
    if (communityData != null) {
       if (communityData['features'] != null && communityData['features'] is List) {
         for (var f in communityData['features']) {
            allAbilities.add({
              'title': f['name'] ?? communityData['name'],
              'desc': f['description'] ?? f['text'] ?? '',
              'source': 'COMUNITÀ',
              'color': Colors.lightBlueAccent
            });
         }
       } else if (communityData['description'] != null || communityData['text'] != null) {
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
          
          // --- SEZIONE 1: TIRO RAPIDO ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2438),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dhGold.withOpacity(0.4)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.casino, color: dhGold),
                    const SizedBox(width: 8),
                    Text("TIRO RAPIDO", style: GoogleFonts.cinzel(color: dhGold, fontWeight: FontWeight.bold, fontSize: 16)),
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
                      backgroundColor: dhGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cinzel'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Per prove di Caratteristica o tiri generici.",
                  style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- SEZIONE 2: ARMI ---
          Text(
            "EQUIPAGGIAMENTO ATTIVO",
            style: GoogleFonts.cinzel(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          
          if (weapons.isEmpty)
             _buildEmptyState("Nessuna arma equipaggiata")
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weapons.length,
              itemBuilder: (context, index) {
                final weaponName = weapons[index];
                return Card(
                  color: const Color(0xFF2C2C2C),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.white10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: dhGold.withOpacity(0.5))
                      ),
                      child: Icon(Icons.colorize, color: dhGold),
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
            ),

          const SizedBox(height: 24),

          // --- SEZIONE 3: TRATTI E ABILITÀ (TUTTI) ---
          if (allAbilities.isNotEmpty) ...[
            Text(
              "CAPACITÀ & BONUS",
              style: GoogleFonts.cinzel(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...allAbilities.map((ability) => _buildAbilityCard(
              context, 
              ability['title'], 
              ability['desc'], 
              ability['source'],
              ability['color']
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10)
      ),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.white30))),
    );
  }

  Widget _buildAbilityCard(BuildContext context, String title, String description, String source, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banda colorata laterale
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
              ),
            ),
            // Contenuto
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title.toUpperCase(), 
                            style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: accentColor.withOpacity(0.5))
                          ),
                          child: Text(source, style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description, 
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)
                    ),
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