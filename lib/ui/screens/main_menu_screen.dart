import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessario per la Clipboard
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../logic/room_provider.dart';
import 'character_list_screen.dart';
import 'gm_room_list_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  // --- LOGICA DIALOGO GESTIONE ID ---
  void _showGmIdentityDialog(BuildContext context) {
    final provider = context.read<RoomProvider>();
    // Assicuriamoci che l'ID sia caricato
    if (provider.userId == null) provider.initUser();
    
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
        title: Text("Identità Game Master", style: GoogleFonts.cinzel(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Questo è il tuo ID univoco. Salvalo per recuperare le tue stanze su un altro dispositivo.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 10),
            
            // BOX ID ATTUALE + COPY
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      provider.userId ?? "Caricamento...",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: dhGold),
                    onPressed: () {
                      if (provider.userId != null) {
                        Clipboard.setData(ClipboardData(text: provider.userId!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("ID copiato negli appunti!"))
                        );
                      }
                    },
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            
            const Text(
              "RECUPERO ACCOUNT",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Text(
              "Hai un vecchio ID? Incollalo qui per ripristinare le tue stanze.",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            
            // INPUT RECUPERO
            TextField(
              controller: recoverController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Incolla qui il tuo vecchio ID",
                hintStyle: TextStyle(color: Colors.white30),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
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
                    const SnackBar(content: Text("ID aggiornato! Le stanze sono state sincronizzate."))
                  );
                }
              }
            },
            child: const Text("Recupera"),
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
                // TITOLO
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

                // PULSANTI MENU
                _buildMenuButton(context, "GIOCATORE", Icons.person, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterListScreen()));
                }),
                
                const SizedBox(height: 20),
                
                _buildMenuButton(context, "GAME MASTER", Icons.security, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GMRoomListScreen()));
                }),

                const SizedBox(height: 40),
                
                // PULSANTE GESTIONE ID (Nuovo)
                TextButton.icon(
                  onPressed: () => _showGmIdentityDialog(context),
                  icon: const Icon(Icons.vpn_key, color: Colors.white54, size: 18),
                  label: const Text("Gestisci ID & Recupero", style: TextStyle(color: Colors.white70)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black45,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                ),
                
                // Tasto Reset (Debug - opzionale)
                // TextButton(
                //   onPressed: () => context.read<RoomProvider>().logout(),
                //   child: const Text("Reset Debug", style: TextStyle(color: Colors.white10)),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.9),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFD4AF37)),
            const SizedBox(width: 12),
            Text(
              text, 
              style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ],
        ),
      ),
    );
  }
}