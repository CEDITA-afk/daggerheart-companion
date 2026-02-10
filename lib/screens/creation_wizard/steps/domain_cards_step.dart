import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/data_repository.dart';
import '../../../models/domain_card.dart';
import '../../../providers/character_state.dart';

class DomainCardsStep extends ConsumerWidget {
  final VoidCallback onNext;

  const DomainCardsStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(dataRepositoryProvider);
    final characterState = ref.watch(characterProvider);
    final selectedClass = characterState.selectedClass;

    if (selectedClass == null) {
      return const Center(child: Text("Please select a Class first."));
    }

    final availableCards = repo.domainCards.where((card) {
      final isLevelOne = card.level == 1;
      final isClassDomain = selectedClass.domains.any((d) => d.toLowerCase() == card.domain.toLowerCase());
      return isLevelOne && isClassDomain;
    }).toList();

    final selectedCount = characterState.selectedDomainCards.length;
    final isComplete = selectedCount == 2;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                "Choose Domain Cards",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Select 2 Level 1 Cards ($selectedCount/2)",
                style: TextStyle(
                  color: isComplete ? Colors.green : Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
            ],
          ),
        ),
        
        if (availableCards.isEmpty)
          const Expanded(child: Center(child: Text("No cards found for these domains.")))
        else
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70, // Carte leggermente più alte per il testo
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: availableCards.length,
              itemBuilder: (context, index) {
                final card = availableCards[index];
                final isSelected = characterState.selectedDomainCards.any((c) => c.id == card.id);
                
                return _DomainCardWidget(
                  card: card,
                  isSelected: isSelected,
                  onTap: () {
                    if (!isSelected && selectedCount >= 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("You can only choose 2 cards!"), duration: Duration(seconds: 1)),
                      );
                      return;
                    }
                    ref.read(characterProvider.notifier).toggleDomainCard(card);
                  },
                  onLongPress: () => _showCardDetails(context, card),
                );
              },
            ),
          ),
          
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: isComplete ? onNext : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).primaryColor,
              disabledBackgroundColor: Colors.grey[800],
            ),
            child: const Text("CONFIRM CARDS", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  void _showCardDetails(BuildContext context, DomainCard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (ctx, scrollCtrl) => _CardDetailSheet(card: card, scrollController: scrollCtrl),
      ),
    );
  }
}

class _DomainCardWidget extends StatelessWidget {
  final DomainCard card;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DomainCardWidget({
    required this.card, 
    required this.isSelected, 
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getDomainColor(card.domain);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.greenAccent : color.withOpacity(0.5),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 8)] : [],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(card.domain.toUpperCase(), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                    if (card.recallCost > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(4)),
                        child: Text("Recall ${card.recallCost}", style: const TextStyle(fontSize: 9, color: Colors.amber)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  card.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 10, thickness: 0.5),
                Text(card.type, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    card.description,
                    style: TextStyle(fontSize: 10, color: Colors.grey[300]),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Positioned(
              top: 5, right: 5,
              child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
            ),
          const Positioned(
            bottom: 5, right: 5,
            child: Icon(Icons.info_outline, color: Colors.grey, size: 16),
          ),
        ],
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

class _CardDetailSheet extends StatelessWidget {
  final DomainCard card;
  final ScrollController scrollController;

  const _CardDetailSheet({required this.card, required this.scrollController});

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
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Text(card.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text("${card.domain} Domain - Level ${card.level}", style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoBox("TYPE", card.type),
              _InfoBox("RECALL COST", card.recallCost.toString()),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          // Usiamo MarkdownBody se hai flutter_markdown o Text normale con stile
          Text(card.description, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }

  Widget _InfoBox(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}