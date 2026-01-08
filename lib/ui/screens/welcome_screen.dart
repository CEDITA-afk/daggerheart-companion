import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Per Clipboard
import '../../logic/room_provider.dart';
import '../../logic/creation_provider.dart';
import 'character_list_screen.dart';
import 'gm_room_list_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // Inizializza il RoomProvider (genera un ID casuale se non esiste)
      Provider.of<RoomProvider>(context, listen: false).init();
      _isInit = true;
    }
  }

  // Mostra il dialog per scegliere l'identità
  void _showIdentityDialog(BuildContext context, bool isGm) {
    final roomProv = Provider.of<RoomProvider>(context, listen: false);
    final creationProv = Provider.of<CreationProvider>(context, listen: false);
    
    // ID attuale (generato automaticamente o salvato)
    final currentId = roomProv.myUserId ?? "Caricamento...";
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Costringe a fare una scelta
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "CHI SEI?", 
          style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        // CORREZIONE: Abbiamo spostato tutto il layout qui dentro per evitare errori
        content: SizedBox(
          width: double.maxFinite, // Occupa la larghezza disponibile
          child: Column(
            mainAxisSize: MainAxisSize.min, // Altezza minima necessaria
            children: [
              Text(
                "Per recuperare i tuoi dati da un altro dispositivo, inserisci qui il tuo Codice di Recupero.",
                style: GoogleFonts.lato(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black45,
                  hintText: "Incolla codice qui...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                "Oppure continua come NUOVO UTENTE con questo codice:",
                style: GoogleFonts.lato(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: currentId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Codice copiato negli appunti!"))
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4AF37))
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentId,
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.copy, color: Color(0xFFD4AF37), size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "(Clicca per copiare e salvare il tuo codice)",
                style: GoogleFonts.lato(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 24),
              
              // --- PULSANTI SPOSTATI QUI DENTRO ---
              Row(
                children: [
                  // BOTTONE 1: Entra con Codice Inserito
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        final inputCode = codeController.text.trim();
                        if (inputCode.isNotEmpty) {
                          await roomProv.forceUserId(inputCode);
                          creationProv.setUserId(inputCode);
                          await creationProv.loadSavedCharacters();
                          
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            _navigate(context, isGm);
                          }
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inserisci un codice valido o usa 'Nuovo Utente'")));
                        }
                      },
                      child: const Text("USA CODICE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // BOTTONE 2: Nuovo Utente
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        creationProv.setUserId(currentId);
                        await creationProv.loadSavedCharacters();
                        
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          _navigate(context, isGm);
                        }
                      },
                      child: const Text("NUOVO UTENTE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        // Actions vuoto perché abbiamo messo i bottoni nel content
        actions: [],
      ),
    );
  }

  void _navigate(BuildContext context, bool isGm) {
    if (isGm) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GmRoomListScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CharacterListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Sfondo con gestione errori immagine
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                  Colors.black,
                ],
              ),
            ),
            // Se l'immagine non c'è, usa solo il gradiente
            child: Image.asset(
              'assets/images/daggerheart_cover.webp',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              opacity: const AlwaysStoppedAnimation(0.4),
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(); // Niente immagine se fallisce il caricamento
              },
            ),
          ),
          
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "DAGGERHEART",
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 48, // Ridotto leggermente per evitare overflow su schermi piccoli
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD4AF37),
                        shadows: [
                          const Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2, 2))
                        ]
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "COMPANION APP",
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        letterSpacing: 4,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),

                    _buildRoleButton(
                      context, 
                      "GIOCATORE", 
                      "Crea il tuo eroe, gestisci equipaggiamento e partecipa alle sessioni.",
                      Icons.person,
                      () => _showIdentityDialog(context, false),
                    ),
                    
                    const SizedBox(height: 20),

                    _buildRoleButton(
                      context, 
                      "GAMEMASTER", 
                      "Crea stanze, gestisci nemici e tieni traccia dell'azione.",
                      Icons.security,
                      () => _showIdentityDialog(context, true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF222222),
            const Color(0xFF222222).withOpacity(0.8),
          ]
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37)),
                    color: Colors.black45
                  ),
                  child: Icon(icon, color: const Color(0xFFD4AF37), size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title, 
                        style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle, 
                        style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}