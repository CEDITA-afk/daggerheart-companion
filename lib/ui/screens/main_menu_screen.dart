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
    // Assicura che l'ID sia caricato
    if (provider.userId == null) provider.init();
    
    final TextEditingController recoverController = TextEditingController();
    final dhGold = Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24), // Sfondo leggermente più scuro
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: dhGold.withOpacity(0.5), width: 1)
        ),
        title: Center(
          child: Text(
            "IDENTITÀ UTENTE", 
            style: GoogleFonts.cinzel(color: dhGold, fontWeight: FontWeight.bold)
          )
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Il tuo ID Personale",
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              // --- BOX VISUALIZZAZIONE ID (COPY) ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12)
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        provider.userId ?? "Caricamento...",
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontFamily: 'Courier', 
                          fontSize: 13
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, color: dhGold),
                      tooltip: "Copia ID",
                      onPressed: () {
                        if (provider.userId != null) {
                          Clipboard.setData(ClipboardData(text: provider.userId!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("ID copiato negli appunti!"),
                              duration: Duration(seconds: 1),
                            )
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              
              const Text(
                "RECUPERO ACCOUNT",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                "Incolla qui un vecchio ID per ripristinare le stanze.",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              
              // --- CAMPO INPUT CON TASTO INCOLLA ---
              TextField(
                controller: recoverController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Incolla ID qui...",
                  hintStyle: TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.black26,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: dhGold)
                  ),
                  // TASTO INCOLLA DEDICATO
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste, color: Colors.white70),
                    tooltip: "Incolla dagli appunti",
                    onPressed: () async {
                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        recoverController.text = data!.text!;
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text("Testo incollato!"), duration: Duration(milliseconds: 500))
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Chiudi", style: TextStyle(color: Colors.white54)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dhGold, 
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  onPressed: () async {
                    String inputId = recoverController.text.trim();
                    if (inputId.isNotEmpty) {
                      // Esegui il recupero
                      await provider.forceUserId(inputId);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Identità aggiornata con successo!"),
                            backgroundColor: Colors.green,
                          )
                        );
                      }
                    }
                  },
                  child: const Text("RECUPERA"),
                ),
              ),
            ],
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
                // LOGO & TITOLO
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
                
                // PULSANTE GESTIONE ID (Stile Link)
                TextButton.icon(
                  onPressed: () => _showIdentityDialog(context),
                  icon: const Icon(Icons.vpn_key, size: 16, color: Colors.white54),
                  label: const Text("Gestione ID & Recupero", style: TextStyle(color: Colors.white54)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), 
                      side: BorderSide(color: Colors.white.withOpacity(0.1))
                    )
                  ),
                ),
                
                const SizedBox(height: 20),
                Text("v1.0.0", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10)),
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
      height: 70, // Leggermente più alto per tocco facile
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.95),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5), // Bordo leggermente più spesso
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.5),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 30),
            const SizedBox(width: 16),
            Text(
              text, 
              style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
            ),
          ],
        ),
      ),
    );
  }
}