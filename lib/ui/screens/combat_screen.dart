import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Assicurati di avere questo import
import '../../logic/combat_provider.dart';
import '../../logic/room_provider.dart';
import '../../logic/gm_provider.dart';
import '../../data/models/adversary.dart';
import '../../data/data_manager.dart';
import '../widgets/adversary_details_dialog.dart';
import 'character_sheet_screen.dart';
import '../widgets/dice_roller_dialog.dart';

class CombatScreen extends StatefulWidget {
  const CombatScreen({super.key});

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {

  // --- DIALOG PER AGGIUNGERE NEMICI CON FILTRI ---
  void _showAddEnemyDialog(BuildContext context, CombatProvider combat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permette al dialog di espandersi
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return _AddAdversaryDialogContent(scrollController: scrollController, combatProvider: combat);
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CombatProvider, RoomProvider, GmProvider>(
      builder: (context, combat, room, gm, child) {
        final enemies = combat.activeEnemies;
        final characters = combat.activeCharacters;

        return Scaffold(
          appBar: AppBar(
            title: const Text("REGIA SCONTRO", style: TextStyle(fontFamily: 'Cinzel')),
            backgroundColor: Colors.red[900],
            actions: [
              IconButton(
                icon: const Icon(Icons.cloud_upload),
                tooltip: "Invia ai Giocatori",
                onPressed: () {
                   List<dynamic> allActive = [...enemies, ...characters];
                   room.syncCombatData(gm.fear, gm.actionTokens, allActive);
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dati inviati ai giocatori!")));
                },
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- EROI ---
              const Text("EROI", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              if (characters.isEmpty) 
                const Padding(padding: EdgeInsets.all(8), child: Text("Nessun eroe.", style: TextStyle(color: Colors.grey))),
              
              ...characters.map((char) => Card(
                color: const Color(0xFF1A237E).withOpacity(0.4),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blueAccent),
                  title: Text(char.name, style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => combat.activeCharacters.removeWhere((c) => c.id == char.id)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CharacterSheetScreen(character: char))),
                ),
              )),

              const SizedBox(height: 24),

              // --- AVVERSARI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("AVVERSARI", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add_circle, color: Colors.redAccent), onPressed: () => _showAddEnemyDialog(context, combat)),
                ],
              ),
              
              ...enemies.map((enemy) => Card(
                color: const Color(0xFFB71C1C).withOpacity(0.2),
                child: ListTile(
                  leading: const Icon(Icons.android, color: Colors.redAccent),
                  title: Text(enemy.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove, size: 16, color: Colors.red), onPressed: () => combat.modifyHp(enemy.id, -1)),
                      Text(" ${enemy.currentHp} / ${enemy.maxHp} ", style: const TextStyle(color: Colors.white)),
                      IconButton(icon: const Icon(Icons.add, size: 16, color: Colors.green), onPressed: () => combat.modifyHp(enemy.id, 1)),
                    ],
                  ),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => combat.removeAdversary(enemy.id)),
                  onTap: () {
                    // Dettagli Nemico
                    showDialog(context: context, builder: (_) => AdversaryDetailsDialog(data: {
                      'name': enemy.name,
                      'tier': enemy.tier,
                      'currentHp': enemy.currentHp,
                      'maxHp': enemy.maxHp,
                      'attack': "${enemy.attackName} (+${enemy.attackMod})",
                      'damage': enemy.damageDice,
                      'difficulty': enemy.difficulty,
                      'moves': enemy.features.map((f) => {
                        'name': f.name,
                        'description': f.text
                      }).toList(),
                    }));
                  },
                ),
              )),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFD4AF37),
            child: const Icon(Icons.casino, color: Colors.black),
            onPressed: () => showDialog(context: context, builder: (_) => const DiceRollerDialog()),
          ),
        );
      },
    );
  }
}

// --- WIDGET CONTENUTO DIALOGO CON FILTRI ---
class _AddAdversaryDialogContent extends StatefulWidget {
  final ScrollController scrollController;
  final CombatProvider combatProvider;

  const _AddAdversaryDialogContent({required this.scrollController, required this.combatProvider});

  @override
  State<_AddAdversaryDialogContent> createState() => _AddAdversaryDialogContentState();
}

class _AddAdversaryDialogContentState extends State<_AddAdversaryDialogContent> {
  List<Adversary> _allAdversaries = [];
  List<Adversary> _filteredAdversaries = [];
  
  // Filtri
  String? _selectedCampaign;
  String? _selectedTierLevel; // "0", "1", "2", ...
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _allAdversaries = DataManager().getAdversaryLibrary();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredAdversaries = _allAdversaries.where((adv) {
        // Filtro Ricerca Testuale
        bool matchesSearch = adv.name.toLowerCase().contains(_searchQuery.toLowerCase());
        
        // Filtro Campagna
        bool matchesCampaign = _selectedCampaign == null || adv.campaign == _selectedCampaign;
        
        // Filtro Tier (Estrae il numero dalla stringa "Tier X ...")
        bool matchesTier = true;
        if (_selectedTierLevel != null) {
          matchesTier = adv.tier.contains("Tier $_selectedTierLevel");
        }

        return matchesSearch && matchesCampaign && matchesTier;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Estrai opzioni uniche per i filtri
    final campaigns = _allAdversaries.map((a) => a.campaign).toSet().toList();
    // Estrai i numeri dei tier (0, 1, 2, ...)
    final tiers = _allAdversaries
        .map((a) {
          final match = RegExp(r'Tier (\d+)').firstMatch(a.tier);
          return match?.group(1);
        })
        .where((t) => t != null)
        .toSet()
        .toList();
    tiers.sort(); // Ordina i tier

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text("AGGIUNGI AVVERSARIO", style: TextStyle(color: Colors.white, fontFamily: 'Cinzel', fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          
          // --- BARRA DI RICERCA ---
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Cerca nome...",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.black38,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (val) {
              _searchQuery = val;
              _applyFilters();
            },
          ),
          
          const SizedBox(height: 12),

          // --- FILTRI CHIPS ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filtro Campagna
                if (campaigns.isNotEmpty) ...[
                  const Text("Origine: ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedCampaign,
                    dropdownColor: const Color(0xFF2C2C2C),
                    hint: const Text("Tutte", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("Tutte", style: TextStyle(color: Colors.white))),
                      ...campaigns.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white))))
                    ],
                    onChanged: (val) {
                      _selectedCampaign = val;
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 16),
                ],

                // Filtro Tier
                if (tiers.isNotEmpty) ...[
                  const Text("Tier: ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedTierLevel,
                    dropdownColor: const Color(0xFF2C2C2C),
                    hint: const Text("Tutti", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
                    items: [
                      const DropdownMenuItem(value: null, child: Text("Tutti", style: TextStyle(color: Colors.white))),
                      ...tiers.map((t) => DropdownMenuItem(value: t, child: Text("Tier $t", style: const TextStyle(color: Colors.white))))
                    ],
                    onChanged: (val) {
                      _selectedTierLevel = val;
                      _applyFilters();
                    },
                  ),
                ]
              ],
            ),
          ),

          const Divider(color: Colors.white24),

          // --- LISTA RISULTATI ---
          Expanded(
            child: _filteredAdversaries.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      _allAdversaries.isEmpty ? "Nessun dato caricato nel DataManager." : "Nessun nemico trovato con questi filtri.", 
                      style: const TextStyle(color: Colors.grey)
                    ),
                  ],
                ),
              )
            : ListView.builder(
                controller: widget.scrollController, // Importante per lo scroll nel bottom sheet
                itemCount: _filteredAdversaries.length,
                itemBuilder: (c, i) {
                  final adv = _filteredAdversaries[i];
                  return Card(
                    color: const Color(0xFF2C2C2C),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red[900], 
                        child: Text(
                          adv.tier.contains("Tier") ? adv.tier.split(" ")[1] : "T", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        )
                      ),
                      title: Text(adv.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        "${adv.tier} • Diff: ${adv.difficulty}\n${adv.campaign}", 
                        style: const TextStyle(color: Colors.grey, fontSize: 11)
                      ),
                      isThreeLine: true,
                      onTap: () {
                        // CLONA E AGGIUNGI
                        final enemyObj = adv.clone();
                        widget.combatProvider.addAdversary(enemyObj);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${enemyObj.name} aggiunto allo scontro!"), duration: const Duration(seconds: 1))
                        );
                      },
                    ),
                  );
                }
              ),
          ),
        ],
      ),
    );
  }
}