import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Import necessario
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// LOGICA PER MOBILE / DESKTOP

// Mantiene la funzione esistente per i JSON
Future<void> saveAndShareFile(String fileName, String jsonStr) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(jsonStr);
  await Share.shareXFiles([XFile(file.path)], text: 'Ecco il file del personaggio!');
}

// --- NUOVA FUNZIONE PER I PDF (DATI BINARI) ---
Future<void> saveBinaryFile(String fileName, Uint8List bytes) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$fileName');
  
  // Scrive i bytes direttamente senza convertirli in Stringa
  await file.writeAsBytes(bytes); 
  
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'application/pdf')], 
    text: 'Ecco la scheda del personaggio!'
  );
}

Future<Map<String, dynamic>?> pickAndReadFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result != null && result.files.single.path != null) {
    File file = File(result.files.single.path!);
    String content = await file.readAsString();
    return jsonDecode(content);
  }
  return null;
}