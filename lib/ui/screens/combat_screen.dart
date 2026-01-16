import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../logic/combat_provider.dart';
import '../../logic/room_provider.dart';
import '../../logic/gm_provider.dart';
import '../../data/models/adversary.dart';
import '../../data/models/character.dart';
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

  // --- 1. DIALOG PER AGGIUNGERE GIOCATORI ---
  void _showAddPlayerDialog(BuildContext context, RoomProvider room, CombatProvider combat) {
    // Filtra i giocatori connessi che NON sono ancora nel combattimento
    final availablePlayers = room.connectedPlayers.where((p) {
      return !combat.activeCharacters.any((c) => c.id == p['id']);
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFD4AF37))),
        title: Text("AGGIUNGI EROE", style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold)),
        content: availablePlayers.isEmpty
            ? const Text("Nessun giocatore disponibile o tutti già presenti.", style: TextStyle(color: Colors.grey))
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availablePlayers.length,
                  itemBuilder: (ctx, index) {
                    final p = availablePlayers[index];
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.blueAccent),
                      title: Text(p['name'] ?? "Sconosciuto", style: const TextStyle(color: Colors.white)),
                      subtitle: Text("Livello ${p['level'] ?? 1}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      trailing: const Icon(Icons.add_circle, color: Colors.green),
                      onTap: () {
                        try {
                          // Converte la mappa JSON in oggetto Character
                          final char = Character.fromJson(p);
                          combat.addCharacter(char);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${char.name} aggiunto!")));
                        } catch (e) {
                          print("Errore aggiunta personaggio: $e");
                        }
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Chiudi", style: TextStyle(color: Colors.white54)))
        ],
      ),
    );
  }

  // --- 2. DIALOG PER AGGIUNGERE NEMICI (CON FILTRI) ---
  void _showAddEnemyDialog(BuildContext context, CombatProvider combat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
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
            backgroundColor: const Color(0xFF1E1E1E),
            actions: [
              // Tasto Sync
              IconButton(
                icon: const Icon(Icons.cloud_upload),
                tooltip: "Invia ai Giocatori",
                onPressed: () {
                   List<dynamic> allActive = [...enemies, ...characters];
                   room.syncCombatData(gm.fear, gm.actionTokens, allActive);
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dati inviati ai giocatori!")));
                },
              ),
              // Tasto Refresh
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => room.init(), 
              )
            ],
          ),
          backgroundColor: const Color(0xFF121212),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              
              // --- SEZIONE EROI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("EROI", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                  // FIX: Tasto Aggiungi Eroe ripristinato
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blueAccent), 
                    onPressed: () => _showAddPlayerDialog(context, room, combat)
                  ),
                ],
              ),
              
              if (characters.isEmpty) 
                const Padding(padding: EdgeInsets.all(8), child: Text("Nessun eroe in combattimento.", style: TextStyle(color: Colors.white30, fontStyle: FontStyle.italic))),
              
              ...characters.map((char) => Card(
                color: const Color(0xFF1A237E).withOpacity(0.4),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blueAccent),
                  title: Text(char.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("HP: ${char.currentHp} / ${char.maxHp}", style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => combat.activeCharacters.removeWhere((c) => c.id == char.id)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CharacterSheetScreen(character: char))),
                ),
              )),

              const SizedBox(height: 24),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),

              // --- SEZIONE AVVERSARI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("AVVERSARI", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.redAccent), 
                    onPressed: () => _showAddEnemyDialog(context, combat)
                  ),
                ],
              ),
              
              if (enemies.isEmpty) 
                const Padding(padding: EdgeInsets.all(8), child: Text("Nessun avversario presente.", style: TextStyle(color: Colors.white30, fontStyle: FontStyle.italic))),

              ...enemies.map((enemy) => Card(
                color: const Color(0xFFB71C1C).withOpacity(0.2),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: Text(enemy.name.substring(0,1), style: const TextStyle(color: Colors.redAccent)),
                  ),
                  title: Text(enemy.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16, color: Colors.red), 
                        onPressed: () => combat.modifyHp(enemy.id, -1),
                        constraints: const BoxConstraints(),
                      ),
                      Text(" ${enemy.currentHp} / ${enemy.maxHp} ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16, color: Colors.green), 
                        onPressed: () => combat.modifyHp(enemy.id, 1),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => combat.removeAdversary(enemy.id)),
                  onTap: () {
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

// --- WIDGET DIALOGO AVANZATO NEMICI (INVARIATO) ---
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
  
  String? _selectedCampaign;
  String? _selectedTierLevel; 
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
        bool matchesSearch = adv.name.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesCampaign = _selectedCampaign == null || adv.campaign == _selectedCampaign;
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
    final campaigns = _allAdversaries.map((a) => a.campaign).toSet().toList();
    final tiers = _allAdversaries
        .map((a) {
          final match = RegExp(r'Tier (\d+)').firstMatch(a.tier);
          return match?.group(1);
        })
        .where((t) => t != null)
        .toSet()
        .toList();
    tiers.sort();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text("AGGIUNGI AVVERSARIO", style: TextStyle(color: Colors.white, fontFamily: 'Cinzel', fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          
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

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
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

          Expanded(
            child: _filteredAdversaries.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      _allAdversaries.isEmpty ? "Nessun dato caricato." : "Nessun nemico trovato.", 
                      style: const TextStyle(color: Colors.grey)
                    ),
                  ],
                ),
              )
            : ListView.builder(
                controller: widget.scrollController,
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
                        final enemyObj = adv.clone();
                        widget.combatProvider.addAdversary(enemyObj);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${enemyObj.name} aggiunto!"), duration: const Duration(seconds: 1))
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