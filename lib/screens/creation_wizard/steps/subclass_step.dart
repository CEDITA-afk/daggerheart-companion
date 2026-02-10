import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/data_repository.dart';
import '../../../models/character_options.dart';
import '../../../providers/character_state.dart';

class SubclassSelectionStep extends ConsumerWidget {
  final VoidCallback onNext;

  const SubclassSelectionStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(dataRepositoryProvider);
    final characterState = ref.watch(characterProvider);
    final selectedClass = characterState.selectedClass;

    if (selectedClass == null) {
      return const Center(child: Text("Please select a Class first."));
    }

    final availableSubclasses = repo.subclasses.where((s) => 
      s.relatedClass.toLowerCase() == selectedClass.name.toLowerCase() ||
      s.relatedClass.toLowerCase() == selectedClass.id.toLowerCase()
    ).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Choose ${selectedClass.name} Specialization",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        if (availableSubclasses.isEmpty)
          const Expanded(child: Center(child: Text("No subclasses found for this class.")))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: availableSubclasses.length,
              itemBuilder: (context, index) {
                final subclass = availableSubclasses[index];
                return _SubclassCard(
                  subclass: subclass,
                  onTap: () => _showSubclassDetails(context, ref, subclass),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showSubclassDetails(BuildContext context, WidgetRef ref, Subclass subclass) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => _SubclassDetailsSheet(
          subclass: subclass,
          scrollController: scrollController,
          onConfirm: () {
            ref.read(characterProvider.notifier).setSubclass(subclass);
            Navigator.pop(ctx);
            onNext(); 
          },
        ),
      ),
    );
  }
}

class _SubclassCard extends StatelessWidget {
  final Subclass subclass;
  final VoidCallback onTap;

  const _SubclassCard({required this.subclass, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      subclass.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subclass.description.split('\n').first, // Mostra solo la prima riga come anteprima
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubclassDetailsSheet extends StatelessWidget {
  final Subclass subclass;
  final ScrollController scrollController;
  final VoidCallback onConfirm;

  const _SubclassDetailsSheet({
    required this.subclass,
    required this.scrollController,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          // Maniglia per il drag
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                // Header
                Text(
                  subclass.name.toUpperCase(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Subclass of ${subclass.relatedClass}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 30),

                // Description Area
                const Text("DESCRIPTION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(subclass.description, style: const TextStyle(fontSize: 16, height: 1.4)),
                const SizedBox(height: 24),

                // Foundation Features (Livello 1)
                if (subclass.foundationFeatures.isNotEmpty) ...[
                  _SectionHeader("FOUNDATION (Level 1)", Colors.green),
                  ...subclass.foundationFeatures.map((f) => _FeatureBox(feature: f)),
                  const SizedBox(height: 20),
                ],

                // Specialization Features (Livello 5)
                if (subclass.specializationFeatures.isNotEmpty) ...[
                  _SectionHeader("SPECIALIZATION (Level 5)", Colors.blue),
                  ...subclass.specializationFeatures.map((f) => _FeatureBox(feature: f)),
                  const SizedBox(height: 20),
                ],

                // Mastery Features (Livello 10)
                if (subclass.masteryFeatures.isNotEmpty) ...[
                  _SectionHeader("MASTERY (Level 10)", Colors.purple),
                  ...subclass.masteryFeatures.map((f) => _FeatureBox(feature: f)),
                  const SizedBox(height: 20),
                ],
                
                const SizedBox(height: 80), // Spazio per il bottone fluttuante
              ],
            ),
          ),
          
          // Confirm Button (Fisso in basso)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("CHOOSE THIS SPECIALIZATION", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.label, size: 16, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: color.withOpacity(0.5))),
        ],
      ),
    );
  }
}

class _FeatureBox extends StatelessWidget {
  final Feature feature;
  const _FeatureBox({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100], // O Colors.grey[900] se sei in dark mode
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(feature.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(feature.description, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
        ],
      ),
    );
  }
}