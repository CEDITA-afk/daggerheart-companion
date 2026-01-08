import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart' show BuildContext, ScaffoldMessenger, SnackBar, Text, Colors;
import '../data/models/character.dart';

// Import condizionale per il salvataggio file
import 'json_ops_mobile.dart' if (dart.library.html) 'json_ops_web.dart' as ops;

class PdfExportService {
  
  static Future<void> printCharacterPdf(BuildContext context, Character char) async {
    try {
      final service = PdfExportService();
      final Uint8List pdfBytes = await service.generateCharacterPdf(char);
      
      String safeName = char.name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      if (safeName.isEmpty) safeName = "character";
      String fileName = "$safeName.pdf";

      // Nota: Per salvare il PDF binario correttamente, convertiamo i bytes in String latin1
      // Questo è un trucco per usare la funzione di salvataggio esistente che accetta stringhe.
      // In un'app reale, è meglio modificare json_ops per accettare List<int>.
      String pdfString = String.fromCharCodes(pdfBytes);
      await ops.saveAndShareFile(fileName, pdfString); 

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF generato! Controlla download o condivisione."), backgroundColor: Colors.green)
        );
      }

    } catch (e) {
      print("Errore PDF: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore export PDF: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  Future<Uint8List> generateCharacterPdf(Character character) async {
    final pdf = pw.Document();

    // --- CARICAMENTO FONT SICURO ---
    pw.Font ttf;
    try {
      final fontData = await rootBundle.load("assets/fonts/Cinzel-Regular.ttf");
      ttf = pw.Font.ttf(fontData);
    } catch (e) {
      print("Font Cinzel non trovato ($e), uso standard Helvetica.");
      ttf = pw.Font.helvetica(); // Fallback sicuro
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(character),
              pw.Divider(),
              pw.SizedBox(height: 10),
              
              // SEZIONE 1: STATISTICHE E RISORSE
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(flex: 3, child: _buildStatsGrid(character)),
                  pw.SizedBox(width: 20),
                  pw.Expanded(flex: 2, child: _buildVitalsSection(character)),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // SEZIONE 2: ARMI
              _buildWeaponsSection(character),
              
              pw.SizedBox(height: 20),
              
              // SEZIONE 3: NOTE E INVENTARIO
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(child: _buildInventorySection(character)),
                  pw.SizedBox(width: 20),
                  pw.Expanded(child: _buildNotesSection(character)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Character char) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(char.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text("Livello ${char.level} - ${char.classId.toUpperCase()}", style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("Razza: ${char.ancestryId}"),
            pw.Text("Comunità: ${char.communityId}"),
            if (char.subclassId != null) pw.Text("Sottoclasse: ${char.subclassId}"),
          ],
        )
      ],
    );
  }

  pw.Widget _buildStatsGrid(Character char) {
    final Map<String, Map<String, String>> statDefinitions = {
      'agilita': {'label': 'Agilità', 'desc': '(Scatta, salta)'},
      'forza': {'label': 'Forza', 'desc': '(Solleva, fracassa)'},
      'astuzia': {'label': 'Finezza', 'desc': '(Controlla, nascondi)'},
      'istinto': {'label': 'Istinto', 'desc': '(Percepisci, fiuta)'},
      'presenza': {'label': 'Presenza', 'desc': '(Affascina, inganna)'},
      'conoscenza': {'label': 'Conoscenza', 'desc': '(Ricorda, analizza)'},
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("TRATTI", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Wrap(
          spacing: 10,
          runSpacing: 10,
          children: statDefinitions.entries.map((entry) {
            final val = char.stats[entry.key] ?? 0;
            return pw.Container(
              width: 100,
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(entry.value['label']!, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      pw.Text(entry.value['desc']!, style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Text("${val >= 0 ? '+' : ''}$val", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // NUOVA SEZIONE PER LE RISORSE MANCANTI
  pw.Widget _buildVitalsSection(Character char) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("RISORSE", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        
        // Evasione e Soglie
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoBox("Evasione", "${char.evasion}"),
            _buildInfoBox("Soglia Magg.", "${char.majorThreshold}"),
            _buildInfoBox("Soglia Grave", "${char.severeThreshold}"),
          ]
        ),
        pw.SizedBox(height: 10),

        // Speranza e Stress
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoBox("Speranza", "${char.hope}"),
            _buildInfoBox("Stress", "${char.currentStress} / ${char.maxStress}"),
          ]
        ),
        pw.SizedBox(height: 10),

        // Armatura
        pw.Container(
          padding: const pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Armatura: ${char.armorName}", style: const pw.TextStyle(fontSize: 10)),
              pw.Text("Punteggio: ${char.armorScore}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInfoBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildWeaponsSection(Character char) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("ARMI ED EQUIPAGGIAMENTO", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          if (char.weapons.isEmpty)
            pw.Text("Nessuna arma equipaggiata.", style: const pw.TextStyle(color: PdfColors.grey600))
          else
            ...char.weapons.map((w) => pw.Text("• $w")).toList(),
        ],
      ),
    );
  }

  pw.Widget _buildInventorySection(Character char) {
    return pw.Container(
      height: 150,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("ZAINO & ORO (${char.gold} mo)", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          if (char.inventory.isEmpty)
            pw.Text("- Vuoto -", style: const pw.TextStyle(color: PdfColors.grey500))
          else
            ...char.inventory.take(8).map((i) => pw.Text("• ${i.split('|')[0]}", style: const pw.TextStyle(fontSize: 9))),
        ],
      ),
    );
  }

  pw.Widget _buildNotesSection(Character char) {
    return pw.Container(
      height: 150,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("NOTE / LEGAMI", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          // Se ci sono legami, stampiamoli
          if (char.narrativeAnswers != null)
            ...char.narrativeAnswers!.entries.take(4).map((e) => 
              pw.Text("${e.key}: ${e.value}", style: const pw.TextStyle(fontSize: 8))
            ),
        ],
      ),
    );
  }
}