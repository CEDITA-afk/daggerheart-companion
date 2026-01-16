import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../logic/room_provider.dart';
import 'character_list_screen.dart';
import 'gm_room_list_screen.dart'; // Assicurati che l'import sia corretto
import 'lobby_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

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

                // PULSANTI
                _buildMenuButton(context, "GIOCATORE", Icons.person, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterListScreen()));
                }),
                
                const SizedBox(height: 20),
                
                _buildMenuButton(context, "GAME MASTER", Icons.security, () {
                  // FIX: Rimossa la parola 'const' qui
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GMRoomListScreen()));
                }),

                const SizedBox(height: 40),
                
                // Opzione Logout Rapido (Debug/Utilità)
                TextButton(
                  onPressed: () {
                    context.read<RoomProvider>().logout();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dati locali resettati.")));
                  },
                  child: const Text("Reset Identità (Logout)", style: TextStyle(color: Colors.white30)),
                )
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