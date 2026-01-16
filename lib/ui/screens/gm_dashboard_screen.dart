import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../logic/room_provider.dart';
import 'combat_screen.dart';

class GmDashboardScreen extends StatelessWidget {
  const GmDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final room = context.watch<RoomProvider>();
    final dhGold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text("DASHBOARD GM", style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              room.exitRoom();
              Navigator.pop(context);
            },
          )
        ],
      ),
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // INFO STANZA
            _buildInfoCard(room, dhGold),
            const SizedBox(height: 20),

            // LISTA GIOCATORI CONNESSI
            Text("GIOCATORI CONNESSI", style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (room.connectedPlayers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Nessun giocatore connesso.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: room.connectedPlayers.length,
                itemBuilder: (ctx, index) {
                  final player = room.connectedPlayers[index];
                  String name = player['name'] ?? "Sconosciuto";
                  
                  return Card(
                    color: const Color(0xFF2A2438),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.person, color: dhGold),
                      title: Text(name, style: const TextStyle(color: Colors.white)),
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),

            // AZIONI RAPIDE GM
            Text("STRUMENTI", style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            _buildActionTile(
              context, 
              "GESTIONE COMBATTIMENTO", 
              Icons.shield, // FIX: Sostituito Icons.swords (non esiste) con Icons.shield
              Colors.redAccent,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CombatScreen()))
            ),
            
            _buildActionTile(
              context, 
              "GESTIONE TOKEN & PAURA", 
              Icons.generating_tokens, 
              Colors.purpleAccent,
              () => _showTokenDialog(context, room)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(RoomProvider room, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Column(
        children: [
          Text("CODICE STANZA", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 4),
          SelectableText(
            room.currentRoomCode ?? "...",
            style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4, fontFamily: 'Courier'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statBox("PAURA", "${room.fear}", Colors.purpleAccent),
              _statBox("TOKEN", "${room.actionTokens}", Colors.orangeAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      color: const Color(0xFF2A2438),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showTokenDialog(BuildContext context, RoomProvider room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2438),
        title: const Text("Gestione Risorse", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _resourceRow("Paura", room.fear, (val) => room.syncCombatData(val, room.actionTokens, room.activeCombatantsData)),
            const SizedBox(height: 20),
            _resourceRow("Token Azione", room.actionTokens, (val) => room.syncCombatData(room.fear, val, room.activeCombatantsData)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Chiudi"))],
      ),
    );
  }

  Widget _resourceRow(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove, color: Colors.red), onPressed: () => onChanged(value > 0 ? value - 1 : 0)),
            Text("$value", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: () => onChanged(value + 1)),
          ],
        )
      ],
    );
  }
}