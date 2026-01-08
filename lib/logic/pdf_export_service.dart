import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/character.dart';
import '../data/data_manager.dart';

class PdfExportService {
  
  // ... (codice precedente invariato fino a _generateDocument) ...

  static Future<pw.Document> _generateDocument(Character char) async {
    final pdf = pw.Document();
    
    final classData = DataManager().getClassById(char.classId);
    final className = classData?['name'] ?? char.classId.toUpperCase();
    final ancestryData = DataManager().getAncestryById(char.ancestryId);
    final communityData = DataManager().getCommunityById(char.communityId);

    // Font
    final fontTitle = await PdfGoogleFonts.cinzelDecorativeBold();
    final fontBody = await PdfGoogleFonts.latoRegular();
    final fontBold = await PdfGoogleFonts.latoBold();
    final fontItalic = await PdfGoogleFonts.latoItalic();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Expanded(child: _buildUnderlinedField("NOME PERSONAGGIO", char.name, fontTitle, 16)),
                  pw.SizedBox(width: 15),
                  // CORREZIONE 1: Aggiunto ?? "" per garantire che non sia null
                  pw.Expanded(child: _buildUnderlinedField("PRONOMI", char.pronouns ?? "", fontBody, 10)),
                  pw.SizedBox(width: 15),
                  pw.Expanded(child: _buildUnderlinedField("CLASSE", className, fontBody, 12)),
                ]
              ),
              
              // ... (Codice intermedio invariato per brevità) ...
              
              pw.Spacer(),
              
              // CORREZIONE 2 & 3: Aggiunto ?? {} per garantire che le mappe non siano null
              _buildDetailSection("BACKGROUND", char.backgroundAnswers ?? {}, fontBold, fontBody, fontItalic),
              pw.SizedBox(height: 10),
              _buildDetailSection("LEGAMI", char.bonds ?? {}, fontBold, fontBody, fontItalic),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // ... (Resto del file helpers invariati) ...
  
  static Future<void> printCharacterPdf(Character char) async {
    final pdf = await _generateDocument(char);
    await Printing.layoutPdf(onLayout: (format) => pdf.save(), name: 'Scheda_${char.name}.pdf');
  }

  static pw.Widget _buildUnderlinedField(String label, String value, pw.Font font, double size) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        pw.Container(
          width: double.infinity,
          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.5))),
          child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: size))
        )
      ]
    );
  }
  
  // Includi qui gli altri metodi helper (_buildAttributeBox, _buildStatBox, ecc.) 
  // che erano già presenti nel file originale senza modifiche.
  
  // (Per brevità ometto i metodi helper che non davano errore, assicurati di tenerli nel file finale)
  static pw.Widget _buildAttributeBox(String label, int value, pw.Font fBold, pw.Font fBody) {
    return pw.Container(margin: const pw.EdgeInsets.only(bottom: 10), child: pw.Row(children: [pw.Container(width: 30, height: 30, alignment: pw.Alignment.center, decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all()), child: pw.Text("$value", style: pw.TextStyle(font: fBold, fontSize: 14))), pw.SizedBox(width: 10), pw.Text(label, style: pw.TextStyle(font: fBold, fontSize: 10))]));
  }
  
  static pw.Widget _buildStatBox(String label, String value, String sub, pw.Font fBold, pw.Font fBody, {PdfColor? borderColor}) {
    return pw.Column(children: [pw.Text(label, style: pw.TextStyle(font: fBold, fontSize: 8)), pw.Container(padding: const pw.EdgeInsets.all(5), decoration: pw.BoxDecoration(border: pw.Border.all(color: borderColor ?? PdfColors.black)), child: pw.Text(value, style: pw.TextStyle(font: fBold, fontSize: 16)))]);
  }
  
  static pw.Widget _buildTrackerBar(String label, int current, int max, PdfColor color, pw.Font fBold) {
    return pw.Row(children: [pw.SizedBox(width: 60, child: pw.Text(label, style: pw.TextStyle(font: fBold, fontSize: 8))), pw.Expanded(child: pw.Wrap(spacing: 2, children: List.generate(max, (i) => pw.Container(width: 8, height: 8, decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: i < current ? color : PdfColors.white, border: pw.Border.all())))))]);
  }

  static pw.Widget _buildDetailSection(String title, Map<String, String> items, pw.Font fBold, pw.Font fBody, pw.Font fItalic) {
    if (items.isEmpty) return pw.Container();
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(title, style: pw.TextStyle(font: fBold, fontSize: 12)), pw.Divider(height: 5, color: PdfColors.grey400), ...items.entries.map((e) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(e.key, style: pw.TextStyle(font: fBold, fontSize: 9)), pw.Text(e.value, style: pw.TextStyle(font: fBody, fontSize: 9)), pw.SizedBox(height: 4)]))]);
  }
}