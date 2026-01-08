import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../logic/room_provider.dart';
import '../../logic/creation_provider.dart';
import 'main_menu_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Controlla se l'utente ha già fatto "login" in passato
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('user_device_id');

    // Ritardo artificiale per evitare flash rapidi e caricare i font
    await Future.delayed(const Duration(milliseconds: 500));

    if (savedId != null && savedId.isNotEmpty) {
      // Login automatico se esiste un ID
      _proceedToApp(savedId);
    } else {
      // Mostra la schermata di login
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _proceedToApp(String userId) async {
    // 1. Inizializza RoomProvider
    final roomProv = Provider.of<RoomProvider>(context, listen: false);
    await roomProv.forceUserId(userId);

    // 2. Inizializza CreationProvider (per caricare i PG)
    final createProv = Provider.of<CreationProvider>(context, listen: false);
    createProv.setUserId(userId);
    // Non aspettiamo il loadCharacters qui per velocità, lo farà la schermata successiva

    if (mounted) {
      // Navigazione: Rimuove la schermata di login dallo stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainMenuScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colori Daggerheart
    const dhGold = Color(0xFFCFB876);
    const dhBackgroundStart = Color(0xFF1A1625);
    const dhBackgroundEnd = Color(0xFF0F0B15);
    const dhSurface = Color(0xFF2A2438);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: dhBackgroundStart,
        body: Center(child: CircularProgressIndicator(color: dhGold)),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. SFONDO
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [dhBackgroundStart, dhBackgroundEnd],
              ),
            ),
          ),
          
          // 2. IMMAGINE ARTISTICA (Opzionale, con gestione errore)
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/daggerheart_cover.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(), // Se manca l'immagine, non fa nulla
              ),
            ),
          ),
          
          // 3. CONTENUTO CENTRALE
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TITOLO
                  Text(
                    "DAGGERHEART",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: dhGold,
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 15, offset: const Offset(0, 4))
                      ]
                    ),
                  ),
                  Text(
                    "COMPANION",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      letterSpacing: 6,
                      color: Colors.white54,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // BOX DI LOGIN
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: dhSurface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: dhGold.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 8))
                      ]
                    ),
                    child: Column(
                      children: [
                        const Text("BENTORNATO", style: TextStyle(fontFamily: 'Cinzel', fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text(
                          "Inserisci il tuo Codice di Recupero per ripristinare i tuoi dati.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        
                        // INPUT CODE
                        TextField(
                          controller: _codeController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: dhGold, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                          cursorColor: dhGold,
                          decoration: InputDecoration(
                            hintText: "es. 171589...",
                            hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 0),
                            filled: true,
                            fillColor: Colors.black38,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: dhGold)),
                            prefixIcon: const Icon(Icons.vpn_key, color: Colors.white30),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // BOTTONE ACCEDI
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              final code = _codeController.text.trim();
                              if (code.isNotEmpty) {
                                _proceedToApp(code);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inserisci un codice valido")));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dhGold,
                              foregroundColor: const Color(0xFF1A1625),
                              elevation: 5,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("ACCEDI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // CREA NUOVO UTENTE
                  TextButton.icon(
                    onPressed: () {
                      final roomProv = Provider.of<RoomProvider>(context, listen: false);
                      // init() genera un nuovo ID se non presente
                      roomProv.init().then((_) {
                        if (roomProv.myUserId != null) {
                          _proceedToApp(roomProv.myUserId!);
                        }
                      });
                    },
                    icon: const Icon(Icons.person_add, size: 18, color: dhGold),
                    label: const Text("CREA NUOVO UTENTE", style: TextStyle(color: dhGold, decoration: TextDecoration.underline)),
                    style: TextButton.styleFrom(foregroundColor: dhGold),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}