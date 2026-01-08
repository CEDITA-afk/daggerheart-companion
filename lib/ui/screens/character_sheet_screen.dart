import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../data/models/character.dart';
import '../../data/data_manager.dart';
import '../../logic/json_data_service.dart';
import '../../logic/pdf_export_service.dart';
import '../../logic/room_provider.dart';

import '../widgets/tabs/status_tab.dart';
import '../widgets/tabs/actions_tab.dart';
import '../widgets/tabs/inventory_tab.dart';
import '../widgets/tabs/cards_tab.dart';
import '../widgets/tabs/battle_tab.dart';

class CharacterSheetScreen extends StatefulWidget {
  final Character character;

  const CharacterSheetScreen({super.key, required this.character});

  @override
  State<CharacterSheetScreen> createState() => _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends State<CharacterSheetScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final char = widget.character;
    final classData = DataManager().getClassById(char.classId);

    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        
        bool isCombatActive = roomProvider.currentRoomCode != null && roomProvider.activeCombatantsData.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(char.name, style: const TextStyle(fontFamily: 'Cinzel', fontSize: 18)),
                Text("Livello ${char.level} ${classData?['name'] ?? 'Eroe'}", style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, char),
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(value: 'save_json', child: Text("Esporta File (JSON)")),
                    const PopupMenuItem(value: 'export_pdf', child: Text("Esporta Scheda (PDF)")),
                  ];
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // TAB BAR
              Container(
                color: const Color(0xFF121212),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildTabItem(0, Icons.person, "STATUS", false),
                      _buildTabItem(1, Icons.flash_on, "AZIONI", false),
                      _buildTabItem(2, Icons.flash_on, "SCONTRO", isCombatActive),
                      _buildTabItem(3, Icons.backpack, "INVENTARIO", false),
                      _buildTabItem(4, Icons.style, "CARTE", false),
                    ],
                  ),
                ),
              ),
              
              // CONTENUTO
              Expanded(
                child: IndexedStack(
                  index: _currentTabIndex,
                  children: [
                    StatusTab(character: char), // <--- CORRETTO: char -> character
                    ActionsTab(character: char),
                    const BattleTab(),
                    InventoryTab(char: char),
                    CardsTab(char: char),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label, bool isAlert) {
    bool isSelected = _currentTabIndex == index;
    Color iconColor = isSelected ? const Color(0xFFD4AF37) : Colors.grey;
    if (isAlert && !isSelected) iconColor = Colors.redAccent;
    if (isAlert && isSelected) iconColor = Colors.red;

    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: isSelected 
              ? Border(bottom: BorderSide(color: iconColor, width: 3)) 
              : null,
          color: isAlert && !isSelected ? Colors.red.withOpacity(0.1) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                fontSize: 10, 
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected || isAlert ? FontWeight.bold : FontWeight.normal
              )
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String value, Character char) async {
    if (value == 'save_json') {
      await JsonDataService.exportCharacterJson(context, char);
    } else if (value == 'export_pdf') {
      // <--- CORRETTO: Chiamata al nuovo metodo statico
      await PdfExportService.printCharacterPdf(context, char);
    }
  }
}