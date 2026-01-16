import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../logic/room_provider.dart';
import 'character_list_screen.dart';
import 'gm_room_list_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _showIdentityDialog(BuildContext context) {
    final provider = context.read<RoomProvider>();
    final TextEditingController recoverController = TextEditingController();
    final dhGold = Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: dhGold, width: 2)),
        title: Center(child: Text("GESTIONE ACCOUNT", style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Il tuo ID Univoco", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: provider.userId ?? ""));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ID copiato!")));
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                child: Row(
                  children: [
                    Expanded(child: Text(provider.userId ?? "...", style: const TextStyle(color: Color(0xFFD4AF37), fontFamily: 'Courier', fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.copy, size: 16, color: Colors.white54)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            const Text("Recupera Profilo Esistente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: recoverController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Incolla qui il tuo vecchio ID",
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true, fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, color: Colors.white70),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) recoverController.text = data!.text!;
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: dhGold, foregroundColor: Colors.black),
            onPressed: () async {
              if (recoverController.text.isNotEmpty) {
                await provider.forceUserId(recoverController.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profilo recuperato con successo!")));
                }
              }
            },
            child: const Text("RECUPERA"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dhGold = Theme.of(context).primaryColor;
    final provider = context.watch<RoomProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/background_main.jpg"), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER UTENTE ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: Colors.black.withOpacity(0.6),
                child: Row(
                  children: [
                    const CircleAvatar(backgroundColor: Color(0xFFD4AF37), child: Icon(Icons.person, color: Colors.black)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("BENTORNATO", style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 10, letterSpacing: 2)),
                          Text("Viaggiatore", style: GoogleFonts.cinzel(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("ID: ${provider.userId?.substring(0, 8) ?? '...'}...", style: const TextStyle(color: Colors.white30, fontSize: 10, fontFamily: 'Courier')),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_backup_restore, color: Colors.white54),
                      tooltip: "Gestisci Account",
                      onPressed: () => _showIdentityDialog(context),
                    )
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("DAGGERHEART", style: GoogleFonts.cinzel(fontSize: 42, fontWeight: FontWeight.bold, color: dhGold, shadows: [const Shadow(blurRadius: 10, color: Colors.black)])),
                        Text("COMPANION", style: GoogleFonts.cinzel(fontSize: 20, color: Colors.white70, letterSpacing: 6)),
                        const SizedBox(height: 60),

                        // --- CARDS SELEZIONE MODALITÀ ---
                        _buildModeCard(
                          context, 
                          "GIOCATORE", 
                          "Gestisci i tuoi eroi e unisciti alle sessioni.", 
                          Icons.person, 
                          Colors.blueAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterListScreen()))
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildModeCard(
                          context, 
                          "GAME MASTER", 
                          "Crea stanze, gestisci mostri e scontri.", 
                          Icons.security, 
                          Colors.redAccent,
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GMRoomListScreen()))
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("v1.1.0 - Consistent Update", style: TextStyle(color: Colors.white24, fontSize: 10)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, String title, String subtitle, IconData icon, Color accentColor, VoidCallback onTap) {
    return Card(
      color: const Color(0xFF1E1E1E).withOpacity(0.9),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: accentColor.withOpacity(0.5))),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: accentColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16)
            ],
          ),
        ),
      ),
    );
  }
}