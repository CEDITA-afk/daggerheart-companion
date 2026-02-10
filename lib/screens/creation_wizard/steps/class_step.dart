import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/data_repository.dart';
import '../../../models/character_options.dart';
import '../../../providers/character_state.dart';

class ClassSelectionStep extends ConsumerWidget {
  final VoidCallback onNext;

  const ClassSelectionStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Leggiamo le classi caricate dal repository
    final repo = ref.watch(dataRepositoryProvider);
    final classes = repo.classes;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Choose your Class",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 colonne
              childAspectRatio: 3 / 2, // Formato rettangolare
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final cls = classes[index];
              return _ClassCard(cls: cls, onSelected: () => _showClassDetails(context, ref, cls));
            },
          ),
        ),
      ],
    );
  }

  void _showClassDetails(BuildContext context, WidgetRef ref, DaggerheartClass cls) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permette al foglio di essere a schermo intero
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => _ClassDetailsSheet(
          cls: cls,
          scrollController: scrollController,
          onConfirm: () {
            // SALVA LA SCELTA NELLO STATO
            ref.read(characterProvider.notifier).setClass(cls);
            Navigator.pop(ctx); // Chiudi il foglio
            onNext(); // Vai al prossimo step
          },
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final DaggerheartClass cls;
  final VoidCallback onSelected;

  const _ClassCard({required this.cls, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelected,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_moon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              cls.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Text(
              "Domains: ${cls.domains.join(', ')}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassDetailsSheet extends StatelessWidget {
  final DaggerheartClass cls;
  final ScrollController scrollController;
  final VoidCallback onConfirm;

  const _ClassDetailsSheet({
    required this.cls,
    required this.scrollController,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        children: [
          // Header
          Center(
            child: Text(
              cls.name.toUpperCase(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
          ),
          const Divider(),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatBadge("HP", cls.startingHitPoints.toString(), Colors.red),
              _StatBadge("Evasion", cls.startingEvasion.toString(), Colors.blue),
              _StatBadge("Domains", cls.domains.join(" & "), Colors.purple),
            ],
          ),
          const SizedBox(height: 20),

          // Description
          const Text("DESCRIPTION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(cls.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),

          // Features
          if (cls.features.isNotEmpty) ...[
            const Text("CLASS FEATURES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ...cls.features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                color: Colors.grey[900], // Sfondo scuro per le feature
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                      const SizedBox(height: 4),
                      Text(f.description, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            )),
          ],

          const SizedBox(height: 40),
          
          // Confirm Button
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("SELECT THIS CLASS", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color),
          ),
          child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }
}