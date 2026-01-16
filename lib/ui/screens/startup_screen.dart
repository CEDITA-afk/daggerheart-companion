import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/room_provider.dart';
import 'main_menu_screen.dart';
import 'gm_dashboard_screen.dart';
import 'combat_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final roomProvider = context.read<RoomProvider>();
    
    // 1. Inizializza l'ID utente e tenta la riconnessione alla stanza
    await roomProvider.init();

    await Future.delayed(const Duration(seconds: 2)); // Splash effect

    if (!mounted) return;

    // 2. Controllo Sessione: Se sono in una stanza, vado alla schermata giusta
    if (roomProvider.currentRoomCode != null) {
      if (roomProvider.isGm) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GmDashboardScreen()),
        );
      } else {
        // Se sono giocatore, devo caricare il personaggio? 
        // Per semplicità, qui mandiamo al combat screen o lobby se implementata
        // Assumiamo che CombatScreen gestisca la vista player
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CombatScreen()),
        );
      }
    } else {
      // 3. Nessuna stanza attiva -> Menu Principale
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "DAGGERHEART",
              style: GoogleFonts.cinzel(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Color(0xFFD4AF37)),
            const SizedBox(height: 20),
            const Text(
              "Caricamento identità...",
              style: TextStyle(color: Colors.white54),
            )
          ],
        ),
      ),
    );
  }
}