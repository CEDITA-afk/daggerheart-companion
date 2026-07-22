import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'logic/creation_provider.dart';
import 'logic/combat_provider.dart';
import 'logic/room_provider.dart';
import 'logic/gm_provider.dart';
import 'data/data_manager.dart';
import 'ui/screens/startup_screen.dart';


void main() {
  runApp(const DaggerheartGMScreen());
}

class DaggerheartGMScreen extends StatelessWidget {
  const DaggerheartGMScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DH GM Screen Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ResponsiveDashboard(),
    );
  }
}

class ResponsiveDashboard extends StatefulWidget {
  const ResponsiveDashboard({super.key});

  @override
  State<ResponsiveDashboard> createState() => _ResponsiveDashboardState();
}

class _ResponsiveDashboardState extends State<ResponsiveDashboard> {
  int _selectedIndex = 0;

  // Le 4 schermate dell'app
  final List<Widget> _pages = const [
    RulesTab(),
    PartyTab(),
    AdversaryTab(),
    NotesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Se lo schermo è largo (iPad o Web)
        if (constraints.maxWidth >= 600) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daggerheart GM Screen', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.menu_book), label: Text('Regole')),
                    NavigationRailDestination(icon: Icon(Icons.shield), label: Text('Party')),
                    NavigationRailDestination(icon: Icon(Icons.warning), label: Text('Avversari')),
                    NavigationRailDestination(icon: Icon(Icons.edit_note), label: Text('Note')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          );
        } else {
          // Se lo schermo è stretto (iPhone)
          return Scaffold(
            appBar: AppBar(
              title: const Text('DH GM Screen', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: _pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.menu_book), label: 'Regole'),
                NavigationDestination(icon: Icon(Icons.shield), label: 'Party'),
                NavigationDestination(icon: Icon(Icons.warning), label: 'Avversari'),
                NavigationDestination(icon: Icon(Icons.edit_note), label: 'Note'),
              ],
            ),
          );
        }
      },
    );
  }
}

// --- CONTENUTI DELLE TAB CON CONSTRAINED BOX PER IPAD ---

class RulesTab extends StatelessWidget {
  const RulesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: const [
            Card(child: ListTile(title: Text('Action Roll (2d12)'), subtitle: Text('Hope Die vs Fear Die. \nSe Hope > Fear: Successo con Speranza.\nSe Fear > Hope: Successo con Conseguenza / Fallimento con Conseguenza.'))),
            Card(child: ListTile(title: Text('Soglie di Danno (Damage Thresholds)'), subtitle: Text('Minor (1 HP) | Major (2 HP) | Severe (3 HP)'))),
          ],
        ),
      ),
    );
  }
}

class PartyTab extends StatelessWidget {
  const PartyTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: const [
            ListTile(leading: Icon(Icons.person), title: Text('Eroe 1 (Rogue)'), subtitle: Text('Evasion: 14 | Armor: 2 | Hope: 3 | Stress: 1/5')),
          ],
        ),
      ),
    );
  }
}

class AdversaryTab extends StatelessWidget {
  const AdversaryTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: const [
            ListTile(leading: Icon(Icons.coronavirus, color: Colors.red), title: Text('Goblin Minion'), subtitle: Text('HP: 1 | Difficulty: 10 | Danno: d6 (Fisico)')),
          ],
        ),
      ),
    );
  }
}

class NotesTab extends StatelessWidget {
  const NotesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: const [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dungeon Attuale', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Il boss ha una probabilità di essere nel dungeon, non è certo.'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
}
