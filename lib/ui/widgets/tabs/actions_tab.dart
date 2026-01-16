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
  Map<String, dynamic>? _companionData;
  bool _isLoadingSpecial = false;

  @override
  void initState() {
    super.initState();
    _loadSpecialData();
  }

  Future<void> _loadSpecialData() async {
    if (widget.character.classId.toLowerCase() == 'ranger') {
      setState(() => _isLoadingSpecial = true);
      try {
        final jsonString = await rootBundle.loadString('assets/data/classes/ranger_companion.json');
        final data = json.decode(jsonString);
        if (mounted) {
          setState(() {
            _companionData = data;
            _isLoadingSpecial = false;
          });
        }
      } catch (e) {
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

  void _rollWeapon(BuildContext context, String weaponName) {
    showDialog(
      context: context,
      builder: (ctx) => DiceRollerDialog(
        character: widget.character,
        initialModifier: 0,
        weaponName: weaponName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dhGold = Theme.of(context).primaryColor;
    final char = widget.character;
    final weapons = char.weapons;
    final dm = DataManager();

    List<Map<String, dynamic>> allAbilities = [];

    final classData = dm.getClassById(char.classId);
    if (classData != null) {
      final features = classData['class_features'] ?? classData['features'] ?? classData['core_features'];
      _addFeaturesToList(features, 'CLASSE', dhGold, allAbilities);

      if (char.subclassId != null && classData['subclasses'] != null) {
        final subclasses = classData['subclasses'] as List;
        final sub = subclasses.firstWhere(
          (s) => s['id'] == char.subclassId || s['name'] == char.subclassId, 
          orElse: () => null
        );
        if (sub != null) {
          allAbilities.add({
            'title': sub['name'],
            'desc': sub['description'] ?? sub['text'] ?? 'Abilità della Sottoclasse',
            'source': 'SOTTOCLASSE',
            'color': Colors.purpleAccent
          });
          _addFeaturesToList(sub['features'], 'SOTTOCLASSE', Colors.purpleAccent, allAbilities);
        }
      }

      if (char.classId.toLowerCase() == 'druido' && classData['beast_forms'] != null) {
         final forms = classData['beast_forms'] as List;
         for (var form in forms) {
           String stats = form['stats'] ?? "";
           String traits = (form['traits'] as List?)?.join(", ") ?? "";
           allAbilities.add({
             'title': "Forma: ${form['name']}",
             'desc': "Stats: $stats\nTratti: $traits",
             'source': 'FORMA BESTIALE',
             'color': Colors.orangeAccent
           });
         }
      }
    }

    if (_companionData != null) {
       final compFeatures = _companionData!['class_features']; 
       _addFeaturesToList(compFeatures, 'COMPAGNO', Colors.green, allAbilities);
    }

    final ancestryData = dm.getAncestryById(char.ancestryId);
    if (ancestryData != null) {
       if (ancestryData['features'] != null) {
         _addFeaturesToList(ancestryData['features'], 'RAZZA', Colors.tealAccent, allAbilities);
       } else {
         allAbilities.add({
            'title': ancestryData['name'],
            'desc': ancestryData['description'] ?? ancestryData['text'] ?? '',
            'source': 'RAZZA',
            'color': Colors.tealAccent
          });
       }
    }

    final communityData = dm.getCommunityById(char.communityId);
    if (communityData != null) {
       if (communityData['features'] != null) {
         _addFeaturesToList(communityData['features'], 'COMUNITÀ', Colors.lightBlueAccent, allAbilities);
       } else {
         allAbilities.add({
            'title': communityData['name'],
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
          _buildQuickRollSection(context, dhGold),
          const SizedBox(height: 24),
          Text("EQUIPAGGIAMENTO ATTIVO", style: GoogleFonts.cinzel(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          if (weapons.isEmpty) _buildEmptyState("Nessuna arma equipaggiata")
          else _buildWeaponsList(context, weapons, dhGold),
          const SizedBox(height: 24),
          Text("CAPACITÀ, PRIVILEGI E BONUS", style: GoogleFonts.cinzel(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          if (allAbilities.isEmpty) const Text("Nessuna abilità attiva trovata.", style: TextStyle(color: Colors.grey))
          else ...allAbilities.map((ab) => _buildAbilityCard(ab)),
          if (_isLoadingSpecial) const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }

  void _addFeaturesToList(dynamic features, String source, Color color, List<Map<String, dynamic>> list) {
    if (features == null) return;
    if (features is List) {
      for (var f in features) {
        list.add({
          'title': f['name'] ?? 'Abilità',
          'desc': f['text'] ?? f['description'] ?? f['effect'] ?? '',
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
          child: ListTile(
            leading: Icon(Icons.colorize, color: color),
            title: Text(weaponName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900, foregroundColor: Colors.white),
              onPressed: () => _rollWeapon(context, weaponName),
              child: const Text("ATTACCA"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text((ability['title'] ?? "").toString().toUpperCase(), style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold))),
                        Text(ability['source'], style: TextStyle(color: ability['color'], fontSize: 9, fontWeight: FontWeight.bold))
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(ability['desc'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
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