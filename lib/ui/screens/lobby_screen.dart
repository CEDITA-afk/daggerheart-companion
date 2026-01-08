import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/room_provider.dart';
import '../../logic/creation_provider.dart';
import '../../data/models/character.dart';
import 'character_sheet_screen.dart'; // Importa la schermata della scheda

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  Character? _selectedCharacter;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Carica i personaggi salvati
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CreationProvider>(context, listen: false).loadSavedCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LOBBY")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<CreationProvider>(
          builder: (context, creationProv, child) {
             return FutureBuilder<List<Character>>(
               future: creationProv.loadSavedCharacters(),
               builder: (context, snapshot) {
                 final chars = snapshot.data ?? [];
                 
                 return Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     TextField(
                       controller: _roomCodeController,
                       decoration: const InputDecoration(labelText: "Codice Stanza"),
                     ),
                     const SizedBox(height: 20),
                     DropdownButtonFormField<Character>(
                       value: _selectedCharacter,
                       hint: const Text("Seleziona Personaggio"),
                       items: chars.map((c) => DropdownMenuItem(
                         value: c,
                         child: Text(c.name),
                       )).toList(),
                       onChanged: (val) => setState(() => _selectedCharacter = val),
                     ),
                     const SizedBox(height: 20),
                     _isLoading
                       ? const CircularProgressIndicator()
                       : ElevatedButton(
                           onPressed: () async {
                             if (_selectedCharacter != null && _roomCodeController.text.isNotEmpty) {
                               setState(() => _isLoading = true);
                               try {
                                 await Provider.of<RoomProvider>(context, listen: false)
                                     .joinRoom(_roomCodeController.text, _selectedCharacter!);
                                 if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => CharacterSheetScreen(character: _selectedCharacter!)),
                                    );
                                 }
                               } catch (e) {
                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore: $e")));
                               } finally {
                                 if(mounted) setState(() => _isLoading = false);
                               }
                             }
                           },
                           child: const Text("ENTRA"),
                         ),
                   ],
                 );
               }
             );
          },
        ),
      ),
    );
  }
}