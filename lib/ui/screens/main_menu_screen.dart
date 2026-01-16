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
    // L'ID è già inizializzato da StartupScreen, ma per sicurezza...
    if (provider.userId == null) provider.init();
    
    final TextEditingController recoverController = TextEditingController();
    final dhGold = Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2438),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: dhGold, width: 2)
        ),
        title: Text("Il tuo ID Utente", style: GoogleFonts.cinzel(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Questo codice ti identifica univocamente. Usalo per recuperare le tue stanze GM su altri dispositivi.",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 15),
            
            // VISUALIZZATORE ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      provider.userId ?? "ID non disponibile",
                      style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontFamily: 'Courier', fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: dhGold),
                    onPressed: () {
                      if (provider.userId != null) {
                        Clipboard.setData(ClipboardData(text: provider.userId!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("ID copiato!"))
                        );
                      }
                    },
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            
            const Text(
              "RECUPERO ACCOUNT",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: recoverController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Incolla qui un vecchio ID...",
                hintStyle: TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Chiudi", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: dhGold, foregroundColor: Colors.black),
            onPressed: () async {
              String inputId = recoverController.text.trim();
              if (inputId.isNotEmpty) {
                // Esegui il recupero
                await provider.forceUserId(inputId);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Account recuperato con successo!"))
                  );
                }
              }
            },
            child: const Text("Recupera ID"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dhGold = Theme.of(context).primaryColor;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_main.jpg"), 
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken)
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                Text(
                  "DAGGERHEART",
                  style: GoogleFonts.cinzel(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: dhGold,
                    shadows: [const Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))]
                  ),
                ),
                Text(
                  "COMPANION",
                  style: GoogleFonts.cinzel(
                    fontSize: 24,
                    color: Colors.white70,
                    letterSpacing: 4
                  ),
                ),
                
                const SizedBox(height: 60),

                // PULSANTE 1: GIOCATORE
                _buildMenuButton(context, "GIOCATORE", Icons.person, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterListScreen()));
                }),
                
                const SizedBox(height: 20),
                
                // PULSANTE 2: GAME MASTER
                _buildMenuButton(context, "GAME MASTER", Icons.security, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GMRoomListScreen()));
                }),

                const SizedBox(height: 60),
                
                // PULSANTE ID / RECUPERO
                TextButton.icon(
                  onPressed: () => _showIdentityDialog(context),
                  icon: const Icon(Icons.vpn_key, size: 16, color: Colors.white54),
                  label: const Text("Gestisci ID & Recupero", style: TextStyle(color: Colors.white54)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black45,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Colors.white10))
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 260,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.95),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 10,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 28),
            const SizedBox(width: 16),
            Text(
              text, 
              style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ],
        ),
      ),
    );
  }
}