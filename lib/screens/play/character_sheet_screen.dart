import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/character_state.dart';
import '../../services/storage_service.dart';
import '../../models/character_options.dart';

class CharacterSheetScreen extends ConsumerWidget {
  const CharacterSheetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final char = ref.watch(characterProvider);
    final notifier = ref.read(characterProvider.notifier);

    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(char.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Lvl ${char.level} ${char.ancestry?.name ?? ''} ${char.selectedClass?.name ?? ''}", 
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "COMBAT", icon: Icon(Icons.shield)),
              Tab(text: "FEATURES", icon: Icon(Icons.auto_awesome)),
              Tab(text: "BIO & INFO", icon: Icon(Icons.menu_book)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                await StorageService.updateCharacter(char);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Character Saved!")));
                }
              },
            )
          ],
        ),
        body: TabBarView(
          children: [
            _buildCombatTab(char, notifier),
            _buildFeaturesTab(char),
            _buildBioTab(char),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: COMBAT (RESPONSIVE) ---
  Widget _buildCombatTab(CharacterDraft char, CharacterNotifier notifier) {
    // LayoutBuilder ci dà le dimensioni del contenitore padre
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Se è più largo di 600px (tablet), usa 6 colonne, altrimenti 3 (telefono)
        final isTablet = width > 600;
        final int crossAxisCount = isTablet ? 6 : 3;
        // Calcola l'aspect ratio per mantenere i box quadrati o rettangolari il giusto
        final double childAspectRatio = isTablet ? 1.2 : 1.1; 

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // VITAL STATS (HP, STRESS, HOPE)
            // Usiamo Wrap per andare a capo se lo schermo è troppo piccolo
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: width / 3.5, // Larghezza dinamica
                  child: _buildResourceCounter("HP", char.currentHp, char.maxHp, Colors.red, (v) => notifier.modifyHp(v)),
                ),
                SizedBox(
                  width: width / 3.5,
                  child: _buildResourceCounter("STRESS", char.stress, 10, Colors.purple, (v) => notifier.modifyStress(v)),
                ),
                SizedBox(
                  width: width / 3.5,
                  child: _buildResourceCounter("HOPE", char.hope, 99, Colors.blue, (v) => notifier.modifyHope(v)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ATTRIBUTES GRID (Dinamica)
            GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildStatBox("Agility", char.agility),
                _buildStatBox("Strength", char.strength),
                _buildStatBox("Finesse", char.finesse),
                _buildStatBox("Instinct", char.instinct),
                _buildStatBox("Presence", char.presence),
                _buildStatBox("Knowledge", char.knowledge),
                // Su tablet mettiamo tutto in riga, su mobile Armor e Evasion vanno sotto
                _buildStatBox("Evasion", char.evasion, color: Colors.indigo),
                _buildStatBox("Armor", char.selectedArmor?.armorScore ?? 0, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),

            // WEAPONS
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("WEAPONS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            ),
            if (char.primaryWeapon != null) _buildWeaponCard(char.primaryWeapon!, "Primary"),
            if (char.secondaryWeapon != null) _buildWeaponCard(char.secondaryWeapon!, "Secondary"),
            if (char.primaryWeapon == null && char.secondaryWeapon == null)
              const Text("No weapons equipped.", style: TextStyle(color: Colors.grey)),
            
            const Divider(),

            // DOMAIN CARDS (ABILITIES)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("ABILITIES & SPELLS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            ),
            if (char.selectedDomainCards.isEmpty) const Text("No domain cards selected.", style: TextStyle(color: Colors.grey)),
            
            // Griglia responsive anche per le carte se siamo su tablet
            isTablet 
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10
                ),
                itemCount: char.selectedDomainCards.length,
                itemBuilder: (ctx, i) => _buildCompactCard(char.selectedDomainCards[i]),
              )
            : Column(
                children: char.selectedDomainCards.map((card) => _buildExpandedCard(card)).toList(),
              ),
          ],
        );
      },
    );
  }

  // Helper per la visualizzazione mobile (Card espandibile)
  Widget _buildExpandedCard(dynamic card) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[900],
      child: ExpansionTile(
        title: Text(card.name, style: TextStyle(color: _getDomainColor(card.domain), fontWeight: FontWeight.bold)),
        subtitle: Text("${card.domain} Lvl ${card.level} • ${card.costString}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(card.description, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  // Helper per la visualizzazione tablet (Card fissa più compatta)
  Widget _buildCompactCard(dynamic card) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(card.name, style: TextStyle(color: _getDomainColor(card.domain), fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                Text("Lvl ${card.level}", style: const TextStyle(fontSize: 10)),
              ],
            ),
            const Divider(height: 10),
            Expanded(child: Text(card.description, style: const TextStyle(fontSize: 11, color: Colors.white70), overflow: TextOverflow.fade)),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: FEATURES ---
  Widget _buildFeaturesTab(CharacterDraft char) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeatureSection("Ancestry: ${char.ancestry?.name}", char.ancestry?.features),
        _buildFeatureSection("Community: ${char.community?.name}", char.community?.features),
        _buildFeatureSection("Class Features", char.selectedClass?.features),
        _buildFeatureSection("Subclass: ${char.subclass?.name}", char.subclass?.features),
      ],
    );
  }

  Widget _buildFeatureSection(String title, List<Feature>? features) {
    if (features == null || features.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
        ),
        ...features.map((f) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(f.description, style: const TextStyle(color: Colors.white70)),
              )
            ],
          ),
        )),
      ],
    );
  }

  // --- TAB 3: BIO & INFO ---
  Widget _buildBioTab(CharacterDraft char) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // DETTAGLI CLASSE/ORIGINI
        const Text("ORIGINS & DETAILS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
        const SizedBox(height: 10),
        _buildInfoCard("Class: ${char.selectedClass?.name}", char.selectedClass?.description),
        _buildInfoCard("Subclass: ${char.subclass?.name}", char.subclass?.description),
        _buildInfoCard("Ancestry: ${char.ancestry?.name}", char.ancestry?.description),
        _buildInfoCard("Community: ${char.community?.name}", char.community?.description),
        
        const SizedBox(height: 20),

        // INVENTORY
        const Text("INVENTORY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
        const SizedBox(height: 10),
        Card(
          color: Colors.grey[850],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 if (char.selectedArmor != null) 
                   Text("• Armor: ${char.selectedArmor!.name} (Score ${char.selectedArmor!.armorScore})", style: const TextStyle(fontSize: 16)),
                 if (char.selectedArmor != null) const SizedBox(height: 8),
                 
                 if (char.startingItems.isNotEmpty)
                   ...char.startingItems.where((i) => i.isNotEmpty).map((item) => Padding(
                     padding: const EdgeInsets.only(bottom: 4.0),
                     child: Text("• $item", style: const TextStyle(fontSize: 16)),
                   )),
                 
                 if (char.startingItems.isEmpty && char.selectedArmor == null) 
                   const Text("No items in inventory.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // BACKGROUND & CONNECTIONS
        if (char.backgroundAnswers.isNotEmpty) ...[
          const Text("BACKGROUND", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(height: 10),
          ...char.backgroundAnswers.entries.map((entry) => _buildLoreCard(entry.key, entry.value)),
          const SizedBox(height: 20),
        ],

        if (char.connectionAnswers.isNotEmpty) ...[
          const Text("CONNECTIONS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(height: 10),
          ...char.connectionAnswers.entries.map((entry) => _buildLoreCard(entry.key, entry.value)),
        ],
      ],
    );
  }

  Widget _buildInfoCard(String title, String? description) {
    if (description == null || description.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(description, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoreCard(String question, String answer) {
    if (answer.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent, fontSize: 13)),
            const SizedBox(height: 6),
            Text(answer, style: const TextStyle(fontSize: 15, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCounter(String label, int value, int max, Color color, Function(int) onModify) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(15),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            children: [
              Text("$value${label == 'HP' ? '/$max' : ''}", 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  InkWell(onTap: () => onModify(-1), child: const Icon(Icons.remove_circle_outline)),
                  const SizedBox(width: 8),
                  InkWell(onTap: () => onModify(1), child: const Icon(Icons.add_circle_outline)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatBox(String label, int value, {Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: color?.withOpacity(0.2) ?? Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color ?? Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(value >= 0 && label != "Evasion" && label != "Armor" ? "+$value" : "$value", 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeaponCard(dynamic weapon, String slot) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(weapon.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${weapon.damage} ${weapon.trait} (${weapon.range})", maxLines: 2, overflow: TextOverflow.ellipsis),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(4)),
          child: Text(slot, style: const TextStyle(fontSize: 10, color: Colors.white)),
        ),
      ),
    );
  }
  
  Color _getDomainColor(String domain) {
    switch (domain.toLowerCase()) {
      case 'blade': return Colors.red;
      case 'bone': return Colors.grey;
      case 'codex': return Colors.blue;
      case 'grace': return Colors.pink;
      case 'midnight': return Colors.purple;
      case 'sage': return Colors.green;
      case 'splendor': return Colors.amber;
      case 'valor': return Colors.orange;
      case 'arcana': return Colors.cyan;
      default: return Colors.white;
    }
  }
}