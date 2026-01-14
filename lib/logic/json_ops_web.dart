import 'dart:convert';
import 'dart:typed_data'; // Import necessario
import 'package:universal_html/html.dart' as html;
import 'package:file_picker/file_picker.dart';

// LOGICA PER IL WEB

// Mantiene la funzione esistente per i JSON (Stringhe)
Future<void> saveAndShareFile(String fileName, String jsonStr) async {
  final bytes = utf8.encode(jsonStr);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

// --- NUOVA FUNZIONE PER I PDF (DATI BINARI) ---
// Questa è quella che manca e che risolve il problema del foglio bianco
Future<void> saveBinaryFile(String fileName, Uint8List bytes) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<Map<String, dynamic>?> pickAndReadFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (result != null) {
    final fileBytes = result.files.first.bytes;
    if (fileBytes != null) {
      String content = utf8.decode(fileBytes);
      return jsonDecode(content);
    }
  }
  return null;
}