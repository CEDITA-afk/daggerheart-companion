import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/creation_provider.dart';

// Import Widgets per gli Step
import '../widgets/step_class_selection.dart';
import '../widgets/step_ancestry.dart';
import '../widgets/step_community.dart';
import '../widgets/step_subclass.dart';
import '../widgets/step_traits_allocation.dart';
import '../widgets/step_derived_stats.dart';
import '../widgets/step_background.dart';
import '../widgets/step_experiences.dart';
import '../widgets/step_equipment.dart';
import '../widgets/step_card_selection.dart';
import '../widgets/step_bonds.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  int _currentStep = 0;

  // Lista ordinata degli step di creazione
  final List<Widget> _steps = [
    const StepClassSelection(),     // 0. Classe
    const StepAncestry(),           // 1. Retaggio
    const StepCommunity(),          // 2. Comunità
    const StepSubclass(),           // 3. Sottoclasse
    const StepTraitsAllocation(),   // 4. Tratti
    const StepDerivedStats(),       // 5. Statistiche Derivate
    const StepBackground(),         // 6. Background
    const StepExperiences(),        // 7. Esperienze
    const StepEquipment(),          // 8. Equipaggiamento
    const StepCardSelection(),      // 9. Carte
    const StepBonds(),              // 10. Legami
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<CreationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Creazione: Passo ${_currentStep + 1} di ${_steps.length}"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          body: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentStep + 1) / _steps.length,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                minHeight: 4,
              ),
              Expanded(
                child: _steps[_currentStep],
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text("INDIETRO", style: TextStyle(color: Colors.white)),
                      )
                    else
                      const SizedBox(),
                      
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        // Sincronizza lo step corrente nel provider per eseguire la validazione corretta
                        provider.currentStep = _currentStep;
                        
                        // Esegue la validazione
                        if (provider.validateCurrentStep()) {
                          // Se tutto OK, procedi
                          if (_currentStep < _steps.length - 1) {
                            setState(() => _currentStep++);
                          } else {
                            // Ultimo step: Salva
                            await provider.saveCharacter();
                            if (context.mounted) Navigator.pop(context);
                          }
                        } else {
                          // Se c'è un errore, mostra SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.validationError ?? "Completa i campi obbligatori."),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            )
                          );
                        }
                      },
                      child: Text(
                        _currentStep == _steps.length - 1 ? "SALVA EROE" : "AVANTI",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}