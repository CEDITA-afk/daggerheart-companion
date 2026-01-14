import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart' show BuildContext, ScaffoldMessenger, SnackBar, Text, Colors;
import '../data/models/character.dart';
import '../data/data_manager.dart';

// Import condizionale per il salvataggio file
import 'json_ops_mobile.dart' if (dart.library.html) 'json_ops_web.dart' as ops;

class PdfExportService {
  
  static const PdfColor dhGold = PdfColor.fromInt(0xFFCFB876);
  static const PdfColor dhDark = PdfColor.fromInt(0xFF2A2438);
  static const PdfColor dhGrey = PdfColor.fromInt(0xFFE0E0E0);

  static Future<void> printCharacterPdf(BuildContext context, Character char) async {
    try {
      final service = PdfExportService();
      final Uint8List pdfBytes = await service.generateCharacterPdf(char);
      
      String safeName = char.name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      if (safeName.isEmpty) safeName = "character";
      String fileName = "$safeName.pdf";

      await ops.saveBinaryFile(fileName, pdfBytes); 

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
    
    // Setup Fonts
    pw.Font ttf;
    pw.Font ttfBold;
    try {
      final fontData = await rootBundle.load("assets/fonts/Cinzel-Regular.ttf");
      ttf = pw.Font.ttf(fontData);
      ttfBold = pw.Font.ttf(fontData); 
    } catch (e) {
      print("Font non trovato, uso standard.");
      ttf = pw.Font.helvetica();
      ttfBold = pw.Font.helveticaBold();
    }
    
    final theme = pw.ThemeData.withFont(base: ttf, bold: ttfBold);

    // --- PAGINA 1: STATUS & STATISTICHE ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: theme,
        build: (ctx) => _buildStatusPage(character),
      ),
    );

    // --- PAGINA 2: AZIONI & CAPACITÀ ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: theme,
        build: (ctx) => _buildActionsPage(character),
      ),
    );

    // --- PAGINA 3: CARTE DOMINIO ---
    if (character.activeCardIds.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          theme: theme,
          build: (ctx) => _buildCardsPage(character),
        ),
      );
    }

    return pdf.save();
  }

  // ==========================================
  // PAGINA 1: STATUS (Layout "Scheda Ufficiale")
  // ==========================================
  pw.Widget _buildStatusPage(Character char) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeaderSection(char),
        pw.SizedBox(height: 10),
        _buildAttributesRow(char),
        pw.SizedBox(height: 15),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Colonna SX: Vitale
              pw.Expanded(
                flex: 4,
                child: pw.Column(
                  children: [
                    _buildDefenseRow(char),
                    pw.SizedBox(height: 10),
                    _buildHealthSection(char),
                    pw.SizedBox(height: 10),
                    _buildHopeSection(char),
                    pw.SizedBox(height: 10),
                    _buildExperiencesSection(char),
                  ],
                ),
              ),
              pw.SizedBox(width: 15),
              // Colonna DX: Equipaggiamento
              pw.Expanded(
                flex: 6,
                child: pw.Column(
                  children: [
                    _buildWeaponsSectionSimple(char),
                    pw.SizedBox(height: 10),
                    _buildActiveArmorSection(char),
                    pw.SizedBox(height: 10),
                    _buildInventorySection(char),
                    pw.SizedBox(height: 10),
                    _buildNotesSection(char),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PAGINA 2: AZIONI & CAPACITÀ
  // ==========================================
  pw.Widget _buildActionsPage(Character char) {
    final dm = DataManager();
    final classData = dm.getClassById(char.classId);
    
    List<Map<String, dynamic>> abilities = [];
    
    // Recupero Abilità Classe
    if (classData != null) {
      final features = classData['class_features'] ?? classData['features'] ?? classData['core_features'];
      if (features is List) {
        for (var f in features) {
          abilities.add({'title': f['name'], 'desc': f['text'] ?? f['description'], 'source': 'CLASSE'});
        }
      }
      // Recupero Sottoclasse
      if (char.subclassId != null && classData['subclasses'] != null) {
        final subs = classData['subclasses'] as List;
        final sub = subs.firstWhere((s) => s['id'] == char.subclassId || s['name'] == char.subclassId, orElse: () => null);
        if (sub != null) {
          abilities.add({'title': sub['name'], 'desc': sub['description'] ?? sub['text'], 'source': 'SOTTOCLASSE'});
          if (sub['features'] is List) {
            for (var f in sub['features']) {
              abilities.add({'title': f['name'], 'desc': f['text'] ?? f['description'], 'source': 'SOTTOCLASSE'});
            }
          }
        }
      }
      // Druido Beastform
      if (char.classId.toLowerCase() == 'druido' && classData['beast_forms'] != null) {
         for (var form in classData['beast_forms']) {
           abilities.add({'title': "Forma: ${form['name']}", 'desc': "Tier ${form['tier']}. ${form['stats']}", 'source': 'FORMA BESTIALE'});
         }
      }
    }
    
    // Recupero Razza e Comunità
    final ancestry = dm.getAncestryById(char.ancestryId);
    if (ancestry != null) {
      if (ancestry['features'] is List) {
         for (var f in ancestry['features']) abilities.add({'title': f['name'], 'desc': f['description'] ?? f['text'], 'source': 'RAZZA'});
      } else {
         abilities.add({'title': ancestry['name'], 'desc': ancestry['description'] ?? ancestry['text'], 'source': 'RAZZA'});
      }
    }
    final community = dm.getCommunityById(char.communityId);
    if (community != null) {
       if (community['features'] is List) {
         for (var f in community['features']) abilities.add({'title': f['name'], 'desc': f['description'] ?? f['text'], 'source': 'COMUNITÀ'});
      } else {
         abilities.add({'title': community['name'], 'desc': community['description'] ?? community['text'], 'source': 'COMUNITÀ'});
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("AZIONI & CAPACITÀ", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: dhDark)),
        pw.Divider(color: dhGold),
        pw.SizedBox(height: 10),
        
        // Elenco Abilità
        ...abilities.map((ab) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: dhGold, width: 4)),
            color: PdfColors.grey100
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text((ab['title'] ?? "").toString().toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text((ab['source'] ?? "").toString().toUpperCase(), style: const pw.TextStyle(fontSize: 8, color: dhDark)),
                ]
              ),
              pw.SizedBox(height: 4),
              pw.Text(ab['desc'] ?? "", style: const pw.TextStyle(fontSize: 10)),
            ]
          )
        )),
      ]
    );
  }

  // ==========================================
  // PAGINA 3: CARTE DOMINIO
  // ==========================================
  pw.Widget _buildCardsPage(Character char) {
    final dm = DataManager();
    final cards = char.activeCardIds.map((id) {
      // CORREZIONE QUI: Usa dm.domainCards invece di dm.getAllCards()
      return dm.domainCards.firstWhere(
        (c) => c['id'] == id, 
        orElse: () => {'name': id, 'description': 'Dati non trovati'}
      );
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("CARTE DOMINIO", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: dhDark)),
        pw.Divider(color: dhGold),
        pw.SizedBox(height: 10),
        
        pw.GridView(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: cards.map((card) {
            String domain = card['domain'] ?? "Generico";
            PdfColor headerColor = dhDark;
            // Semplice logica colori per dominio
            if (domain.contains('Blade')) headerColor = PdfColors.red900;
            if (domain.contains('Codex')) headerColor = PdfColors.blue900;
            if (domain.contains('Splendor')) headerColor = PdfColors.orange900;
            if (domain.contains('Bone')) headerColor = PdfColors.grey900;
            if (domain.contains('Sage')) headerColor = PdfColors.green900;
            
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: dhDark),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))
              ),
              child: pw.Column(
                children: [
                  // Card Header
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: headerColor,
                      borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(7))
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(card['name'] ?? "Carta", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text("Lvl ${card['level'] ?? 1}", style: const pw.TextStyle(color: dhGold, fontSize: 10)),
                      ]
                    )
                  ),
                  // Card Body
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(domain.toUpperCase(), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            card['description'] ?? card['text'] ?? "...", 
                            style: const pw.TextStyle(fontSize: 9),
                            maxLines: 8,
                          ),
                        ]
                      )
                    )
                  )
                ]
              )
            );
          }).toList()
        )
      ]
    );
  }

  // ==========================================
  // WIDGET HELPER CONDIVISI (PAGINA 1)
  // ==========================================

  pw.Widget _buildHeaderSection(Character char) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        color: dhDark,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(char.name.toUpperCase(), style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text("${char.ancestryId} - ${char.communityId} - ${char.subclassId ?? 'Nessuna Sottoclasse'}", style: const pw.TextStyle(color: dhGold, fontSize: 10)),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: dhGold, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))
            ),
            child: pw.Column(
              children: [
                pw.Text("LIVELLO", style: const pw.TextStyle(color: dhGold, fontSize: 8)),
                pw.Text("${char.level}", style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text(char.classId.toUpperCase(), style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
              ]
            )
          )
        ],
      ),
    );
  }

  pw.Widget _buildAttributesRow(Character char) {
    final stats = ['agilita', 'forza', 'astuzia', 'istinto', 'presenza', 'conoscenza'];
    final labels = ['Agilità', 'Forza', 'Finezza', 'Istinto', 'Presenza', 'Conoscenza'];
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: List.generate(stats.length, (index) {
        final val = char.stats[stats[index]] ?? 0;
        return pw.Container(
          width: 50,
          child: pw.Column(
            children: [
              pw.Container(
                height: 40, width: 40,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: dhDark, width: 2),
                  borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(5), bottom: pw.Radius.circular(20)),
                ),
                child: pw.Text("${val >= 0 ? '+' : ''}$val", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 2),
              pw.Text(labels[index].toUpperCase(), style: const pw.TextStyle(fontSize: 7, color: dhDark)),
            ],
          ),
        );
      }),
    );
  }

  pw.Widget _buildDefenseRow(Character char) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildShieldValue("EVASIONE", "${char.evasion}"),
        _buildShieldValue("ARMATURA", "${char.armorScore}"),
      ]
    );
  }

  pw.Widget _buildShieldValue(String label, String value) {
    return pw.Column(
      children: [
        pw.Container(
          width: 50, height: 50,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: dhGold, width: 3),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(25)),
          ),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8))
      ]
    );
  }

  pw.Widget _buildHealthSection(Character char) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: dhGrey)),
      child: pw.Column(
        children: [
          pw.Text("DANNI & SALUTE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Divider(thickness: 0.5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildThreshold("MINORE", "1 PF", "1-${char.majorThreshold - 1}"),
              _buildThreshold("MAGGIORE", "2 PF", "${char.majorThreshold}-${char.severeThreshold - 1}"),
              _buildThreshold("SEVERO", "3 PF", "${char.severeThreshold}+"),
            ]
          ),
          pw.SizedBox(height: 10),
          pw.Row(children: [
              pw.Text("PF:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 5),
              pw.Wrap(spacing: 2, children: List.generate(char.maxHp, (i) => _buildCheckbox(filled: i < char.currentHp)))
          ]),
          pw.SizedBox(height: 5),
          pw.Row(children: [
              pw.Text("STRESS:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 5),
              pw.Wrap(spacing: 2, children: List.generate(char.maxStress, (i) => _buildCheckbox(filled: i < char.currentStress)))
          ]),
        ],
      ),
    );
  }

  pw.Widget _buildThreshold(String title, String cost, String range) {
    return pw.Column(children: [
      pw.Text(title, style: const pw.TextStyle(fontSize: 6)),
      pw.Container(padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2), color: dhGrey, child: pw.Text(cost, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
      pw.Text(range, style: const pw.TextStyle(fontSize: 8)),
    ]);
  }

  pw.Widget _buildHopeSection(Character char) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: dhGold), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
      child: pw.Column(children: [
          pw.Text("SPERANZA", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: dhGold)),
          pw.SizedBox(height: 5),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: List.generate(6, (i) => 
            pw.Container(margin: const pw.EdgeInsets.symmetric(horizontal: 2), width: 12, height: 12, child: pw.Transform.rotate(angle: 0.785, child: pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all(color: dhGold), color: i < char.hope ? dhGold : null))))
          ))
      ])
    );
  }

  pw.Widget _buildExperiencesSection(Character char) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: dhGrey)),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("ESPERIENZE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Divider(thickness: 0.5),
          if (char.experiences.isEmpty) pw.Text("- Nessuna -", style: const pw.TextStyle(fontSize: 8)),
          ...char.experiences.map((e) => pw.Text("• $e (+2)", style: const pw.TextStyle(fontSize: 9)))
      ])
    );
  }

  pw.Widget _buildWeaponsSectionSimple(Character char) {
    String primary = "Pugni (d4)";
    String secondary = "-";
    if (char.weapons.isNotEmpty) primary = char.weapons[0];
    if (char.weapons.length > 1) secondary = char.weapons[1];

    return pw.Column(children: [
      _buildSectionTitle("ARMI ATTIVE"),
      pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(5), decoration: pw.BoxDecoration(border: pw.Border.all(color: dhGrey)), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("PRIMARIA", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: dhDark)),
          pw.Text(primary, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Divider(thickness: 0.5),
          pw.Text("SECONDARIA", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: dhDark)),
          pw.Text(secondary, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ]))
    ]);
  }

  pw.Widget _buildActiveArmorSection(Character char) {
    return pw.Column(children: [
      _buildSectionTitle("ARMATURA ATTIVA"),
      pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(5), decoration: pw.BoxDecoration(border: pw.Border.all(color: dhGrey)), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text(char.armorName.isEmpty ? "Nessuna" : char.armorName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text("Punteggio: ${char.armorScore}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ]),
          pw.Divider(thickness: 0.5),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text("Slot Armatura: ", style: const pw.TextStyle(fontSize: 8)),
              pw.Wrap(spacing: 2, children: List.generate(char.maxArmorSlots, (i) => _buildCheckbox(filled: i < char.armorSlotsUsed, isSquare: true)))
          ])
      ]))
    ]);
  }

  pw.Widget _buildInventorySection(Character char) {
    return pw.Column(children: [
      _buildSectionTitle("INVENTARIO & ORO"),
      pw.Container(width: double.infinity, height: 100, padding: const pw.EdgeInsets.all(5), decoration: pw.BoxDecoration(border: pw.Border.all(color: dhGrey)), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
             pw.Text("ORO: ${char.gold}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          ]),
          pw.Divider(thickness: 0.5),
          if (char.inventory.isEmpty) pw.Text("- Vuoto -", style: const pw.TextStyle(color: PdfColors.grey500))
          else ...char.inventory.take(12).map((i) => pw.Text("• ${i.split('|')[0]}", style: const pw.TextStyle(fontSize: 9))),
      ]))
    ]);
  }

  pw.Widget _buildNotesSection(Character char) {
     return pw.Column(children: [
       _buildSectionTitle("NOTE & LEGAMI"),
       pw.Container(width: double.infinity, height: 80, padding: const pw.EdgeInsets.all(5), decoration: pw.BoxDecoration(border: pw.Border.all(color: dhGrey)), child: 
         (char.narrativeAnswers != null) ? 
           pw.Column(children: char.narrativeAnswers!.entries.take(3).map((e) => pw.Text("${e.key}: ${e.value}", style: const pw.TextStyle(fontSize: 8))).toList()) 
           : pw.Text(" ")
       )
     ]);
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(width: double.infinity, alignment: pw.Alignment.center, margin: const pw.EdgeInsets.only(bottom: 2), padding: const pw.EdgeInsets.symmetric(vertical: 2), color: dhDark, child: pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)));
  }

  pw.Widget _buildCheckbox({required bool filled, bool isSquare = false}) {
    return pw.Container(width: 10, height: 10, decoration: pw.BoxDecoration(shape: isSquare ? pw.BoxShape.rectangle : pw.BoxShape.circle, border: pw.Border.all(color: dhDark), color: filled ? dhDark : null));
  }
}