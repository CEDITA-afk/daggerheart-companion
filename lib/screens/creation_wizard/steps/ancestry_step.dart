import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/data_repository.dart';
import '../../../models/character_options.dart';
import '../../../providers/character_state.dart';

class AncestrySelectionStep extends ConsumerWidget {
  final VoidCallback onNext;

  const AncestrySelectionStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(dataRepositoryProvider);
    final ancestries = repo.ancestries;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Choose your Ancestry",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 colonne
              childAspectRatio: 1.4, // Leggermente più bassi delle classi
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: ancestries.length,
            itemBuilder: (context, index) {
              final ancestry = ancestries[index];
              return _AncestryCard(
                ancestry: ancestry,
                onTap: () => _showAncestryDetails(context, ref, ancestry),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAncestryDetails(BuildContext context, WidgetRef ref, Ancestry ancestry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => _AncestryDetailsSheet(
          ancestry: ancestry,
          scrollController: scrollController,
          onConfirm: () {
            ref.read(characterProvider.notifier).setAncestry(ancestry);
            Navigator.pop(ctx);
            onNext();
          },
        ),
      ),
    );
  }
}

class _AncestryCard extends StatelessWidget {
  final Ancestry ancestry;
  final VoidCallback onTap;

  const _AncestryCard({required this.ancestry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              ancestry.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AncestryDetailsSheet extends StatelessWidget {
  final Ancestry ancestry;
  final ScrollController scrollController;
  final VoidCallback onConfirm;

  const _AncestryDetailsSheet({
    required this.ancestry,
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
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  ancestry.name.toUpperCase(),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 30),

                const Text("DESCRIPTION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(ancestry.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),

                if (ancestry.features.isNotEmpty) ...[
                  const Text("ANCESTRY FEATURES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  ...ancestry.features.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Card(
                      color: Colors.grey[900],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary)),
                            const SizedBox(height: 4),
                            Text(f.description, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
          
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
                child: const Text("CHOOSE THIS ANCESTRY", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}