import 'dart:convert';
import 'dart:io' show File; // Importiamo File solo per mobile, con cautela
import 'dart:typed_data'; // <--- ECCO L'IMPORT CHE MANCAVA PER Uint8List
import 'package:flutter/foundation.dart' show kIsWeb; // Per controllare se siamo su Web
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/character_state.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import 'creation_wizard/wizard_screen.dart';
import 'play/character_sheet_screen.dart';

final savedCharactersProvider = FutureProvider<List<CharacterDraft>>((ref) async {
  return await StorageService.loadCharacters();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(savedCharactersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daggerheart Companion"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: "Import JSON",
            onPressed: () => _importCharacter(context, ref),
          )
        ],
      ),
      body: charactersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (characters) {
          if (characters.isEmpty) return _buildEmptyState();
          return _buildCharacterList(context, ref, characters);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const WizardScreen())
          );
          ref.refresh(savedCharactersProvider);
        },
        label: const Text("Create New"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 20),
          const Text("No characters found.", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCharacterList(BuildContext context, WidgetRef ref, List<CharacterDraft> characters) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final char = characters[index];
        return Dismissible(
          key: Key(char.name + index.toString()),
          background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
          onDismissed: (_) async {
             await StorageService.deleteCharacter(index);
             ref.refresh(savedCharactersProvider);
          },
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[800],
                child: Text(
                  char.name.isNotEmpty ? char.name[0].toUpperCase() : "?",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              title: Text(char.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text("Lvl ${char.level} ${char.ancestry?.name} ${char.selectedClass?.name}"),
              
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.share, color: Colors.amber),
                onSelected: (value) {
                  if (value == 'json') {
                    _exportAsJsonFile(char);
                  } else if (value == 'pdf') {
                    _exportAsPdf(char);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'json',
                    child: Row(children: [Icon(Icons.data_object, size: 20), SizedBox(width: 10), Text('Export JSON File')]),
                  ),
                  const PopupMenuItem<String>(
                    value: 'pdf',
                    child: Row(children: [Icon(Icons.picture_as_pdf, size: 20), SizedBox(width: 10), Text('Export PDF Sheet')]),
                  ),
                ],
              ),
              
              onTap: () {
                ref.read(characterProvider.notifier).loadCharacter(char);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CharacterSheetScreen()))
                    .then((_) => ref.refresh(savedCharactersProvider));
              },
            ),
          ),
        );
      },
    );
  }

  // --- LOGICA EXPORT JSON (WEB & MOBILE COMPATIBILE) ---
  Future<void> _exportAsJsonFile(CharacterDraft char) async {
    // 1. Converti in Stringa
    final jsonStr = const JsonEncoder.withIndent('  ').convert(char.toJson());
    
    // 2. Converti la stringa in Bytes (necessario per XFile)
    final Uint8List bytes = utf8.encode(jsonStr);
    
    // 3. Crea il nome del file
    final fileName = "${char.name.replaceAll(' ', '_')}.json";

    // 4. Crea un XFile direttamente dai dati in memoria (Funziona su Web e Mobile!)
    final xFile = XFile.fromData(
      bytes,
      mimeType: 'application/json',
      name: fileName,
    );

    // 5. Condividi/Scarica
    // Su Mobile apre il menu condividi. Su Web scarica il file.
    await Share.shareXFiles([xFile], text: 'Daggerheart JSON: ${char.name}');
  }

  // --- LOGICA EXPORT PDF ---
  Future<void> _exportAsPdf(CharacterDraft char) async {
    await PdfService.exportCharacterPdf(char);
  }

  // --- LOGICA IMPORT JSON (WEB & MOBILE COMPATIBILE) ---
  Future<void> _importCharacter(BuildContext context, WidgetRef ref) async {
    try {
      // Pick file (i bytes sono caricati automaticamente su web)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Importante per il Web: carica i dati in memoria
      );

      if (result != null) {
        String jsonString;
        
        if (kIsWeb) {
          // SU WEB: Leggiamo i bytes direttamente
          final bytes = result.files.single.bytes;
          if (bytes == null) throw "No data found in file";
          jsonString = utf8.decode(bytes);
        } else {
          // SU MOBILE: Leggiamo dal percorso
          final path = result.files.single.path;
          if (path == null) throw "No file path found";
          File file = File(path);
          jsonString = await file.readAsString();
        }
        
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        final newChar = CharacterDraft.fromJson(jsonMap);
        await StorageService.saveCharacter(newChar);
        
        ref.refresh(savedCharactersProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imported ${newChar.name}!")));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error importing: $e")));
      }
    }
  }
}