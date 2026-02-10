import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/class_defaults.dart';
import '../../../providers/character_state.dart';

class BackgroundStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const BackgroundStep({super.key, required this.onNext});

  @override
  ConsumerState<BackgroundStep> createState() => _BackgroundStepState();
}

class _BackgroundStepState extends ConsumerState<BackgroundStep> {
  final _nameController = TextEditingController();
  final Map<String, TextEditingController> _bgControllers = {};
  final Map<String, TextEditingController> _connControllers = {};

  @override
  void initState() {
    super.initState();
    final state = ref.read(characterProvider);
    _nameController.text = state.name == "New Character" ? "" : state.name;
    
    state.backgroundAnswers.forEach((k, v) => _bgControllers[k] = TextEditingController(text: v));
    state.connectionAnswers.forEach((k, v) => _connControllers[k] = TextEditingController(text: v));
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var c in _bgControllers.values) c.dispose();
    for (var c in _connControllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterProvider);
    final selectedClass = characterState.selectedClass;

    if (selectedClass == null) return const SizedBox();

    final guide = classDefaults[selectedClass.name.toUpperCase()];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Identity & Lore", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // 1. NOME
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Character Name",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (val) => ref.read(characterProvider.notifier).setName(val),
          ),
          const SizedBox(height: 30),

          if (guide != null) ...[
            // 2. STARTING ITEM (Logica Aggiornata)
            const Text("Starting Inventory", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            const Text("Make a choice for each line:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            
            // Iteriamo su ogni riga di scelta (es. riga 0: pozioni, riga 1: oggetti narrativi)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: guide.inventoryChoices.length,
              itemBuilder: (context, index) {
                final choiceLine = guide.inventoryChoices[index];
                // Splittiamo la stringa "A OR B" in ["A", "B"]
                final options = choiceLine.split(" OR ").map((e) => e.trim()).toList();
                
                // Recuperiamo la selezione attuale per questa riga specifica
                String currentSelection = "";
                if (characterState.startingItems.length > index) {
                  currentSelection = characterState.startingItems[index];
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Choice ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ...options.map((option) => RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: currentSelection,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: Theme.of(context).primaryColor,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(characterProvider.notifier).setStartingItem(index, val);
                            }
                          },
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // 3. BACKGROUND QUESTIONS
            const Text("Background Questions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 10),
            ...guide.backgroundQuestions.map((q) => _buildQuestionField(q, _bgControllers, (ans) {
              ref.read(characterProvider.notifier).setBackgroundAnswer(q, ans);
            })),
            const SizedBox(height: 30),

            // 4. CONNECTIONS
            const Text("Connections", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 10),
            ...guide.connections.map((q) => _buildQuestionField(q, _connControllers, (ans) {
              ref.read(characterProvider.notifier).setConnectionAnswer(q, ans);
            })),
          ],

          const SizedBox(height: 40),
          
          ElevatedButton(
            onPressed: _nameController.text.isNotEmpty ? widget.onNext : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text("FINISH CREATION", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuestionField(String question, Map<String, TextEditingController> controllers, Function(String) onChanged) {
    controllers.putIfAbsent(question, () => TextEditingController());
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          TextField(
            controller: controllers[question],
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Your answer...",
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}