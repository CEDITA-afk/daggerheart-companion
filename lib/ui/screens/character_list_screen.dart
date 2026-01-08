import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Per Clipboard
import 'package:provider/provider.dart';
import '../../logic/creation_provider.dart';
import '../../logic/room_provider.dart';
import '../../data/models/character.dart';
import 'character_sheet_screen.dart';
import 'wizard_screen.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  @override
  void initState() {
    super.initState();
    // Inizializza l'ID utente nel CreationProvider usando quello del RoomProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomProv = Provider.of<RoomProvider>(context, listen: false);
      final creationProv = Provider.of<CreationProvider>(context, listen: false);
      
      // Assicuriamoci che l'ID sia inizializzato
      if (roomProv.myUserId == null) {
        roomProv.init().then((_) {
           creationProv.setUserId(roomProv.myUserId!);
           creationProv.loadSavedCharacters();
        });
      } else {
        creationProv.setUserId(roomProv.myUserId!);
        creationProv.loadSavedCharacters();
      }
    });
  }

  void _showRecoveryDialog(BuildContext context) {
    final roomProv = Provider.of<RoomProvider>(context, listen: false);
    final myId = roomProv.myUserId ?? "Non disponibile";
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text("SALVATAGGIO CLOUD", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Il tuo Codice di Recupero :", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            SelectableText(myId, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            const Text("Per recuperare i dati su un altro dispositivo, inserisci qui il tuo vecchio codice:", style: TextStyle(color: Colors.white70)),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Incolla qui il codice...",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CHIUDI"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Imposta manualmente il nuovo ID nel sistema
                roomProv.forceUserId(controller.text.trim());
                Provider.of<CreationProvider>(context, listen: false).setUserId(controller.text.trim());
                Provider.of<CreationProvider>(context, listen: false).loadSavedCharacters();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profilo recuperato!")));
              }
            },
            child: const Text("RECUPERA", style: TextStyle(color: Colors.black)),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("I TUOI EROI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync),
            tooltip: "Codice Recupero / Sync",
            onPressed: () => _showRecoveryDialog(context),
          )
        ],
      ),
      body: Consumer<CreationProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<List<Character>>(
            future: provider.loadSavedCharacters(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final characters = snapshot.data ?? [];

              if (characters.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.person_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Nessun personaggio trovato.", style: TextStyle(color: Colors.grey)),
                      Text("Creane uno nuovo o usa l'icona Cloud per recuperare.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final char = characters[index];
                  return Card(
                    color: const Color(0xFF2C2C2C),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.person, color: Colors.black)),
                      title: Text(char.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text("Livello ${char.level} ${char.classId}", style: const TextStyle(color: Colors.grey)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CharacterSheetScreen(character: char)));
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => provider.deleteCharacter(char.id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Provider.of<CreationProvider>(context, listen: false).resetDraft();
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WizardScreen()));
        },
      ),
    );
  }
}