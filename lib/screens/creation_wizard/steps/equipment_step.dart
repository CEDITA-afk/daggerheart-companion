import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/data_repository.dart';
import '../../../data/class_defaults.dart';
import '../../../models/equipment.dart';
import '../../../providers/character_state.dart';

class EquipmentStep extends ConsumerWidget {
  final VoidCallback onNext;

  const EquipmentStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(dataRepositoryProvider);
    final characterState = ref.watch(characterProvider);
    final selectedClass = characterState.selectedClass;

    if (selectedClass == null) return const SizedBox();

    // Trova i suggerimenti per la classe attuale
    final guide = classDefaults[selectedClass.name.toUpperCase()];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Starting Equipment", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          if (guide != null)
            _buildQuickLoadoutCard(context, ref, guide, repo),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          
          const Text("Manual Selection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          
          // Selettori Manuali (Semplificati per ora)
          _buildWeaponSelector(
            context, ref, 
            "Primary Weapon", 
            repo.weapons, 
            characterState.primaryWeapon,
            (w) => ref.read(characterProvider.notifier).setPrimaryWeapon(w)
          ),
          
          _buildWeaponSelector(
            context, ref, 
            "Secondary Weapon", 
            repo.weapons, 
            characterState.secondaryWeapon,
            (w) => ref.read(characterProvider.notifier).setSecondaryWeapon(w)
          ),

          _buildArmorSelector(
            context, ref,
            "Armor",
            repo.armors,
            characterState.selectedArmor,
            (a) => ref.read(characterProvider.notifier).setArmor(a)
          ),

          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: (characterState.primaryWeapon != null && characterState.selectedArmor != null) 
                  ? onNext : null,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("CONFIRM EQUIPMENT"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickLoadoutCard(BuildContext context, WidgetRef ref, ClassGuide guide, DataRepository repo) {
    return Card(
      color: Colors.indigo.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_fix_high, color: Colors.amber),
                const SizedBox(width: 10),
                const Text("Suggested Loadout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 10),
            Text("Primary: ${guide.primaryWeapon}", style: const TextStyle(color: Colors.white70)),
            if (guide.secondaryWeapon != null)
              Text("Secondary: ${guide.secondaryWeapon}", style: const TextStyle(color: Colors.white70)),
            Text("Armor: ${guide.armor}", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // Logica per trovare e applicare gli oggetti
                final pWeapon = _findWeapon(repo.weapons, guide.primaryWeapon);
                final sWeapon = guide.secondaryWeapon != null ? _findWeapon(repo.weapons, guide.secondaryWeapon!) : null;
                final armor = _findArmor(repo.armors, guide.armor);

                if (pWeapon != null) ref.read(characterProvider.notifier).setPrimaryWeapon(pWeapon);
                if (sWeapon != null) ref.read(characterProvider.notifier).setSecondaryWeapon(sWeapon);
                if (armor != null) ref.read(characterProvider.notifier).setArmor(armor);

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Suggested loadout equipped!")));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              child: const Text("Equip Suggestions"),
            )
          ],
        ),
      ),
    );
  }

  Weapon? _findWeapon(List<Weapon> list, String name) {
    try {
      // Cerca per nome (ignorando case)
      return list.firstWhere((w) => w.name.toLowerCase().contains(name.toLowerCase()));
    } catch (e) {
      return null;
    }
  }

  Armor? _findArmor(List<Armor> list, String name) {
    try {
      return list.firstWhere((a) => a.name.toLowerCase().contains(name.toLowerCase()));
    } catch (e) {
      return null;
    }
  }

  Widget _buildWeaponSelector(BuildContext context, WidgetRef ref, String label, List<Weapon> options, Weapon? current, Function(Weapon) onSelect) {
    return ListTile(
      title: Text(label),
      subtitle: Text(current?.name ?? "None Selected"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showModalBottomSheet(context: context, builder: (_) => ListView(
          children: options.map((w) => ListTile(
            title: Text(w.name),
            subtitle: Text("${w.damage} ${w.trait} (${w.range})"),
            onTap: () {
              onSelect(w);
              Navigator.pop(context);
            },
          )).toList(),
        ));
      },
    );
  }

  Widget _buildArmorSelector(BuildContext context, WidgetRef ref, String label, List<Armor> options, Armor? current, Function(Armor) onSelect) {
    return ListTile(
      title: Text(label),
      subtitle: Text(current?.name ?? "None Selected"),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showModalBottomSheet(context: context, builder: (_) => ListView(
          children: options.map((a) => ListTile(
            title: Text(a.name),
            subtitle: Text("Score: ${a.armorScore}"),
            onTap: () {
              onSelect(a);
              Navigator.pop(context);
            },
          )).toList(),
        ));
      },
    );
  }
}