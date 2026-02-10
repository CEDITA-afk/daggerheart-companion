import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/character_state.dart';
import '../models/character_options.dart';

class PdfService {
  // Colori "Printer Friendly" (Bianco e Nero)
  static const PdfColor _black = PdfColors.black;
  static const PdfColor _darkGrey = PdfColors.grey800;
  static const PdfColor _lightGrey = PdfColors.grey400;

  static Future<void> exportCharacterPdf(CharacterDraft char) async {
    final doc = pw.Document();

    // 1. CARICAMENTO FONT
    // Usiamo Cinzel per i titoli (stile Fantasy) e Roboto per il testo (leggibile e supporta simboli)
    final fontTitle = await PdfGoogleFonts.cinzelBold();
    final fontBody = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    // 2. TEMA GLOBALE
    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(font: fontBody, fontSize: 10),
        // Definiamo stili personalizzati che useremo manualmente
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          return [
            // --- HEADER ---
            _buildHeader(char, fontTitle),
            pw.SizedBox(height: 15),
            pw.Divider(thickness: 1, color: _black),
            pw.SizedBox(height: 15),

            // --- STATS & VITALS ---
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Colonna Sinistra: Attributi (Agility, Strength...)
                pw.Expanded(flex: 3, child: _buildAttributesGrid(char, fontTitle)),
                pw.SizedBox(width: 20),
                // Colonna Destra: HP, Stress, Hope, Armor
                pw.Expanded(flex: 2, child: _buildVitalsSection(char, fontTitle)),
              ],
            ),
            pw.SizedBox(height: 20),

            // --- EQUIPMENT TABLE ---
            _buildSectionTitle("WEAPONS & EQUIPMENT", fontBold),
            _buildWeaponsTable(char, fontBold),
            pw.SizedBox(height: 5),
            _buildInventoryText(char, fontItalic),
            
            pw.SizedBox(height: 20),

            // --- DOMAIN CARDS ---
            _buildSectionTitle("DOMAIN ABILITIES", fontBold),
            _buildCardsGrid(char, fontBold),

            pw.SizedBox(height: 20),

            // --- FEATURES (FULL TEXT) ---
            _buildSectionTitle("FEATURES & TRAITS", fontBold),
            _buildFeatureBlock("ANCESTRY: ${char.ancestry?.name}", char.ancestry?.features, fontBold),
            _buildFeatureBlock("COMMUNITY: ${char.community?.name}", char.community?.features, fontBold),
            _buildFeatureBlock("CLASS: ${char.selectedClass?.name}", char.selectedClass?.features, fontBold),
            _buildFeatureBlock("SUBCLASS: ${char.subclass?.name}", char.subclass?.features, fontBold),

            pw.SizedBox(height: 20),

            // --- BIO & LORE ---
            _buildSectionTitle("BACKGROUND & CONNECTIONS", fontBold),
            _buildLoreSection(char, fontBold),
          ];
        },
      ),
    );

    // Nome file sicuro per il salvataggio
    final safeName = char.name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    await Printing.sharePdf(bytes: await doc.save(), filename: '${safeName}_sheet.pdf');
  }

  // ===================== WIDGETS =====================

  static pw.Widget _buildHeader(CharacterDraft char, pw.Font fontTitle) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(char.name.toUpperCase(), style: pw.TextStyle(font: fontTitle, fontSize: 30)),
            pw.Text(
              "Level ${char.level} ${char.ancestry?.name ?? ''} ${char.selectedClass?.name ?? ''} - ${char.subclass?.name ?? ''}",
              style: const pw.TextStyle(fontSize: 12, color: _darkGrey),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: _black, width: 2)),
          child: pw.Text("DAGGERHEART", style: pw.TextStyle(font: fontTitle, fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  static pw.Widget _buildAttributesGrid(CharacterDraft char, pw.Font fontTitle) {
    return pw.Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _attributeBox("Agility", char.agility, fontTitle),
        _attributeBox("Strength", char.strength, fontTitle),
        _attributeBox("Finesse", char.finesse, fontTitle),
        _attributeBox("Instinct", char.instinct, fontTitle),
        _attributeBox("Presence", char.presence, fontTitle),
        _attributeBox("Knowledge", char.knowledge, fontTitle),
      ],
    );
  }

  static pw.Widget _attributeBox(String label, int value, pw.Font font) {
    return pw.Container(
      width: 65,
      height: 65,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _black, width: 1.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(label.toUpperCase(), style: const pw.TextStyle(fontSize: 7, color: _darkGrey)),
          pw.SizedBox(height: 2),
          pw.Text(
            value >= 0 ? "+$value" : "$value",
            style: pw.TextStyle(font: font, fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildVitalsSection(CharacterDraft char, pw.Font fontTitle) {
    return pw.Column(
      children: [
        // EVASION & ARMOR (Valori Numerici)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _derivedStat("EVASION", "${char.evasion}", fontTitle),
            _derivedStat("ARMOR", "${char.selectedArmor?.armorScore ?? 0}", fontTitle),
          ],
        ),
        pw.SizedBox(height: 15),
        
        // TRACKERS (Quadratini vuoti da riempire)
        _buildTrackBar("HIT POINTS", char.maxHp, isCircle: true),
        pw.SizedBox(height: 6),
        _buildTrackBar("STRESS", 10), // Standard 10 Stress
        pw.SizedBox(height: 6),
        _buildTrackBar("HOPE", 6), // Standard Hope slots
        pw.SizedBox(height: 6),
        _buildTrackBar("ARMOR SLOTS", 6), // Slot per assorbire danni
      ],
    );
  }

  static pw.Widget _derivedStat(String label, String value, pw.Font font) {
    return pw.Container(
      width: 70,
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _black),
        borderRadius: pw.BorderRadius.circular(4),
        color: _lightGrey,
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  /// Disegna una barra di quadratini o cerchi VUOTI
  static pw.Widget _buildTrackBar(String label, int count, {bool isCircle = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        pw.Wrap(
          spacing: 3,
          runSpacing: 3,
          children: List.generate(count, (index) {
            return pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _black, width: 1), // Solo bordo nero
                shape: isCircle ? pw.BoxShape.circle : pw.BoxShape.rectangle,
              ),
            );
          }),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.only(bottom: 2),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _black, width: 2)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(font: fontBold, fontSize: 10),
      ),
    );
  }

  static pw.Widget _buildWeaponsTable(CharacterDraft char, pw.Font fontBold) {
    final weapons = <dynamic>[];
    if (char.primaryWeapon != null) weapons.add(char.primaryWeapon);
    if (char.secondaryWeapon != null) weapons.add(char.secondaryWeapon);

    if (weapons.isEmpty) return pw.Text("No weapons equipped.", style: const pw.TextStyle(color: _darkGrey));

    return pw.Table(
      border: pw.TableBorder.all(color: _lightGrey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // Name
        1: const pw.FlexColumnWidth(3), // Traits
        2: const pw.FlexColumnWidth(2), // Damage
      },
      children: [
        // Intestazione Tabella
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _lightGrey),
          children: [
            _tableCell("WEAPON", fontBold, align: pw.TextAlign.left),
            _tableCell("TRAITS & RANGE", fontBold, align: pw.TextAlign.center),
            _tableCell("DAMAGE", fontBold, align: pw.TextAlign.right),
          ]
        ),
        // Righe Armi
        ...weapons.map((w) => pw.TableRow(
          children: [
            _tableCell(w.name, fontBold, align: pw.TextAlign.left),
            _tableCell("${w.trait} (${w.range})", fontBold, align: pw.TextAlign.center, isNormal: true),
            _tableCell(w.damage, fontBold, align: pw.TextAlign.right),
          ]
        )),
      ],
    );
  }

  static pw.Widget _tableCell(String text, pw.Font fontBold, {pw.TextAlign align = pw.TextAlign.left, bool isNormal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text, 
        textAlign: align,
        style: pw.TextStyle(
          font: isNormal ? null : fontBold, 
          fontSize: 9,
          fontWeight: isNormal ? null : pw.FontWeight.bold
        )
      ),
    );
  }

  static pw.Widget _buildInventoryText(CharacterDraft char, pw.Font fontItalic) {
    final items = <String>[];
    if (char.selectedArmor != null) items.add("Armor: ${char.selectedArmor!.name}");
    items.addAll(char.startingItems.where((i) => i.isNotEmpty));

    if (items.isEmpty) return pw.SizedBox.shrink();

    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Text("Inventory: ${items.join(', ')}", style: pw.TextStyle(font: fontItalic, fontSize: 9)),
    );
  }

  static pw.Widget _buildCardsGrid(CharacterDraft char, pw.Font fontBold) {
    if (char.selectedDomainCards.isEmpty) return pw.Text("No cards selected.");

    return pw.Wrap(
      spacing: 15,
      runSpacing: 15,
      children: char.selectedDomainCards.map((c) {
        return pw.Container(
          width: 220,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _black),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text(c.name.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 10))),
                  pw.Text("${c.domain} ${c.level}", style: const pw.TextStyle(fontSize: 8, color: _darkGrey)),
                ],
              ),
              pw.Divider(thickness: 0.5),
              pw.Text(c.type.toUpperCase(), style: const pw.TextStyle(fontSize: 7, color: _darkGrey)),
              pw.SizedBox(height: 4),
              pw.Text(c.description, style: const pw.TextStyle(fontSize: 8)),
              if (c.recallCost > 0)
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Text("Recall: ${c.recallCost}", style: pw.TextStyle(font: fontBold, fontSize: 8)),
                  ),
                )
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildFeatureBlock(String title, List<Feature>? features, pw.Font fontBold) {
    if (features == null || features.isEmpty) return pw.SizedBox.shrink();

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 10, decoration: pw.TextDecoration.underline)),
          pw.SizedBox(height: 2),
          ...features.map((f) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("- ", style: const pw.TextStyle(fontSize: 10)), 
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      style: const pw.TextStyle(fontSize: 9),
                      children: [
                        pw.TextSpan(text: "${f.name}: ", style: pw.TextStyle(font: fontBold)),
                        pw.TextSpan(text: f.description),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  static pw.Widget _buildLoreSection(CharacterDraft char, pw.Font fontBold) {
    final allQA = {...char.backgroundAnswers, ...char.connectionAnswers};
    if (allQA.isEmpty) return pw.Text("No background details provided.", style: const pw.TextStyle(fontSize: 9));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: allQA.entries.map((e) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(e.key, style: pw.TextStyle(fontSize: 9, font: fontBold, color: _darkGrey)),
            pw.Text(e.value, style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      )).toList(),
    );
  }
}