import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/creation_provider.dart';
import '../../logic/room_provider.dart';
import '../../data/models/character.dart';
import 'character_sheet_screen.dart';
import 'wizard_screen.dart';
import 'lobby_screen.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh dei personaggi all'avvio della schermata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomProv = Provider.of<RoomProvider>(context, listen: false);
      final creationProv = Provider.of<CreationProvider>(context, listen: false);
      if (roomProv.myUserId != null) {
        creationProv.setUserId(roomProv.myUserId!);
        creationProv.loadSavedCharacters();
      }
    });
  }

  // LOGICA PER UNIRSI ALLA STANZA
  void _joinRoomDialog(BuildContext context, Character character) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: Text("UNISCITI ALLA PARTITA", style: GoogleFonts.cinzel(color: const Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Entra come: ${character.name}", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Codice Stanza (6 cifre)",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black26,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ANNULLA")),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Codice troppo corto")));
                return;
              }
              Navigator.pop(ctx); // Chiudi dialog
              
              try {
                // Chiamata al provider per unirsi
                await Provider.of<RoomProvider>(context, listen: false).joinRoom(code, character);
                
                if (mounted) {
                  // Vai alla Lobby
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LobbyScreen()));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.red));
              }
            },
            child: const Text("ENTRA"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("I TUOI EROI"),
        // Il tasto back torna automaticamente al Main Menu grazie al Navigator
      ),
      body: Consumer<CreationProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<List<Character>>(
            future: provider.loadSavedCharacters(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
              }
              final characters = snapshot.data ?? [];

              if (characters.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text("Non hai ancora creato nessun eroe.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final char = characters[index];
                  return Card(
                    color: const Color(0xFF2C2C2C),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFD4AF37),
                              child: Text(char.name.isNotEmpty ? char.name[0].toUpperCase() : "?", 
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                            ),
                            title: Text(char.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text("Livello ${char.level} ${char.classId}", style: const TextStyle(color: Colors.grey)),
                            trailing: IconButton(
                              // CORRETTO: Uso [400] e rimosso const
                              icon: Icon(Icons.delete, color: Colors.red[400]),
                              onPressed: () => provider.deleteCharacter(char.id),
                            ),
                          ),
                          const Divider(color: Colors.white10),
                          Row(
                            children: [
                              // TASTO SCHEDA
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.description, size: 18),
                                  label: const Text("SCHEDA"),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => CharacterSheetScreen(character: char)));
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // TASTO GIOCA (ENTRA IN STANZA)
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.login, size: 18),
                                  label: const Text("GIOCA"),
                                  // CORRETTO: fontWeight spostato dentro textStyle
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37), 
                                    foregroundColor: Colors.black,
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () => _joinRoomDialog(context, char),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD4AF37),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("NUOVO EROE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () {
          Provider.of<CreationProvider>(context, listen: false).resetDraft();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WizardScreen()));
        },
      ),
    );
  }
}