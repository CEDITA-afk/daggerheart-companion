import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../logic/room_provider.dart';
import '../../data/models/character.dart';
import '../../data/models/adversary.dart';
import '../widgets/adversary_details_dialog.dart';
import '../widgets/dice_roller_dialog.dart';

class CombatScreen extends StatefulWidget {
  const CombatScreen({super.key});

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {
  // --- UI GESTIONE AGGIUNTA ---
  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2438),
        title: Text("Aggiungi Combattente", style: GoogleFonts.cinzel(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  tabs: [Tab(text: "GIOCATORI"), Tab(text: "NEMICI")],
                  indicatorColor: Color(0xFFD4AF37),
                  labelColor: Color(0xFFD4AF37),
                  unselectedLabelColor: Colors.grey,
                ),
                SizedBox(
                  height: 300,
                  child: TabBarView(
                    children: [
                      _buildPlayersList(context),
                      _buildAdversariesList(context), // Da implementare con lista nemici o manuale
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Chiudi", style: TextStyle(color: Colors.white54)),
          )
        ],
      ),
    );
  }

  Widget _buildPlayersList(BuildContext context) {
    final room = context.watch<RoomProvider>();
    
    // Filtra i giocatori che sono già in combattimento
    final availablePlayers = room.connectedPlayers.where((p) {
      return !room.activeCombatantsData.any((c) => c['id'] == p['id']);
    }).toList();

    if (availablePlayers.isEmpty) {
      return const Center(child: Text("Nessun giocatore disponibile o tutti già in combattimento.", style: TextStyle(color: Colors.white30), textAlign: TextAlign.center));
    }

    return ListView.builder(
      itemCount: availablePlayers.length,
      itemBuilder: (ctx, index) {
        final playerMap = availablePlayers[index];
        return ListTile(
          leading: const Icon(Icons.person, color: Colors.blueAccent),
          title: Text(playerMap['name'] ?? "Sconosciuto", style: const TextStyle(color: Colors.white)),
          subtitle: Text("Livello ${playerMap['level'] ?? 1}", style: const TextStyle(color: Colors.white54)),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: () {
              // CREA OGGETTO CHARACTER DAL JSON
              try {
                final char = Character.fromJson(playerMap);
                
                // AGGIUNGI ALLA LISTA E SINCRONIZZA
                final updatedList = List.from(room.activeCombatantsData);
                updatedList.add(char); // RoomProvider gestirà la conversione in JSON nel metodo sync
                
                room.syncCombatData(room.fear, room.actionTokens, updatedList);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${char.name} aggiunto al combattimento!")));
              } catch (e) {
                print("Errore parsing character: $e");
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Errore nei dati del personaggio.")));
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildAdversariesList(BuildContext context) {
    // Esempio statico o da DataManager
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.adb, color: Colors.redAccent),
          title: const Text("Nemico Generico (Manuale)", style: TextStyle(color: Colors.white)),
          onTap: () {
             // Logica per aggiungere un nemico custom
             // Per brevità, qui non implementata, ma simile ai player
          },
        ),
        // Qui potresti caricare i nemici dal DataManager
      ],
    );
  }

  // --- UI PRINCIPALE ---
  @override
  Widget build(BuildContext context) {
    final room = context.watch<RoomProvider>();
    final isGm = room.isGm;
    final dhGold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text("COMBAT TRACKER", style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          if (isGm)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showAddDialog(context),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => room.init(), // Refresh manuale
          )
        ],
      ),
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // BARRA TOKEN E PAURA
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: const Color(0xFF1E1E24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _counter(isGm, "PAURA", room.fear, Colors.purpleAccent, (v) => room.syncCombatData(v, room.actionTokens, room.activeCombatantsData)),
                _counter(isGm, "TOKEN", room.actionTokens, dhGold, (v) => room.syncCombatData(room.fear, v, room.activeCombatantsData)),
              ],
            ),
          ),
          
          // LISTA COMBATTENTI
          Expanded(
            child: room.activeCombatantsData.isEmpty
                ? const Center(child: Text("Nessun combattimento attivo.", style: TextStyle(color: Colors.white30)))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: room.activeCombatantsData.length,
                    onReorder: (oldIndex, newIndex) {
                      if (!isGm) return;
                      if (newIndex > oldIndex) newIndex -= 1;
                      final items = List.from(room.activeCombatantsData);
                      final item = items.removeAt(oldIndex);
                      items.insert(newIndex, item);
                      room.syncCombatData(room.fear, room.actionTokens, items);
                    },
                    itemBuilder: (context, index) {
                      final data = room.activeCombatantsData[index];
                      // Gestione sicura del dato (potrebbe essere mappa o oggetto)
                      final isPlayer = data is Character || (data is Map && data['isPlayer'] == true);
                      final String name = data is Map ? (data['name'] ?? "?") : (data as dynamic).name;
                      final int hp = data is Map ? (data['currentHp'] ?? 0) : (data as dynamic).currentHp;
                      final int maxHp = data is Map ? (data['maxHp'] ?? 1) : (data as dynamic).maxHp;
                      final String id = data is Map ? (data['id'] ?? index.toString()) : (data as dynamic).id;

                      return Card(
                        key: ValueKey(id),
                        color: isPlayer ? const Color(0xFF2A3B4F) : const Color(0xFF3F2A2A),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () {
                               if (!isPlayer && isGm) {
                                 // FIX: Corretto il nome del parametro 'adversaryData' -> 'data'
                                 showDialog(context: context, builder: (_) => AdversaryDetailsDialog(data: data));
                               }
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.black38,
                              child: Text(name.substring(0, 1), style: TextStyle(color: isPlayer ? Colors.blue : Colors.red)),
                            ),
                          ),
                          title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: (hp / maxHp).clamp(0.0, 1.0),
                                backgroundColor: Colors.black,
                                valueColor: AlwaysStoppedAnimation(hp < maxHp / 3 ? Colors.red : Colors.green),
                              ),
                              const SizedBox(height: 4),
                              Text("$hp / $maxHp PF", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                          trailing: isGm ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 20),
                                onPressed: () {
                                  // Logica danno rapido (modifica locale e sync)
                                  final newItem = Map<String, dynamic>.from(data);
                                  newItem['currentHp'] = (hp - 1).clamp(0, maxHp);
                                  
                                  final newList = List.from(room.activeCombatantsData);
                                  newList[index] = newItem;
                                  room.syncCombatData(room.fear, room.actionTokens, newList);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  final newList = List.from(room.activeCombatantsData);
                                  newList.removeAt(index);
                                  room.syncCombatData(room.fear, room.actionTokens, newList);
                                },
                              )
                            ],
                          ) : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: dhGold,
        onPressed: () => showDialog(context: context, builder: (_) => const DiceRollerDialog()),
        child: const Icon(Icons.casino, color: Colors.black),
      ),
    );
  }

  Widget _counter(bool isGm, String label, int value, Color color, Function(int) onChange) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        Row(
          children: [
            if (isGm)
              IconButton(
                icon: const Icon(Icons.remove, size: 16, color: Colors.white54), 
                onPressed: () => onChange(value > 0 ? value - 1 : 0),
                constraints: const BoxConstraints(),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("$value", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            if (isGm)
              IconButton(
                icon: const Icon(Icons.add, size: 16, color: Colors.white54), 
                onPressed: () => onChange(value + 1),
                constraints: const BoxConstraints(),
              ),
          ],
        )
      ],
    );
  }
}