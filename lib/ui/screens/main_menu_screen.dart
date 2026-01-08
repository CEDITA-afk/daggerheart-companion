import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../logic/room_provider.dart';
import 'character_list_screen.dart';
import 'gm_room_list_screen.dart';
import 'startup_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usiamo watch così se myId diventa null la UI si aggiorna (anche se navighiamo via)
    final roomProv = Provider.of<RoomProvider>(context);
    final myId = roomProv.myUserId ?? "Loading...";

    return Scaffold(
      appBar: AppBar(
        title: const Text("MENU PRINCIPALE"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Esci / Cambia Utente",
            onPressed: () async {
              // 1. Esegui il logout completo (cancella ID da SharedPreferences)
              await Provider.of<RoomProvider>(context, listen: false).logout();
              
              // 2. Naviga alla schermata di Login
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const StartupScreen()),
                  (route) => false // Rimuove tutte le schermate precedenti dallo stack
                );
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // BOX IDENTITÀ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  const Text("IL TUO CODICE UTENTE", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SelectableText(myId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: myId));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Codice Copiato!")));
                        },
                      )
                    ],
                  ),
                  const Text("Salva questo codice per recuperare i dati su altri dispositivi.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            
            const Spacer(),

            // TASTO GIOCATORE
            _buildMenuButton(
              context,
              "GIOCATORE",
              "Gestisci i tuoi eroi e unisciti alle partite.",
              Icons.person,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterListScreen())),
            ),

            const SizedBox(height: 24),

            // TASTO GM
            _buildMenuButton(
              context,
              "GAME MASTER",
              "Crea stanze, nemici e gestisci lo scontro.",
              Icons.security,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GmRoomListScreen())),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFD4AF37).withOpacity(0.1)),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 32),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}