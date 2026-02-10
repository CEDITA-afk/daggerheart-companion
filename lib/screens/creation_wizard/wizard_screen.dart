import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'steps/class_step.dart';
import 'steps/subclass_step.dart';
import 'steps/ancestry_step.dart';
import 'steps/community_step.dart';
import 'steps/attributes_step.dart';
import 'steps/domain_cards_step.dart';
import 'steps/equipment_step.dart';
import 'steps/background_step.dart';
// CORREZIONE IMPORT: Solo due livelli per tornare a "lib"
import '../../services/storage_service.dart';
import '../../providers/character_state.dart';

class WizardScreen extends ConsumerStatefulWidget {
  const WizardScreen({super.key});

  @override
  ConsumerState<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends ConsumerState<WizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  late final List<Widget> _steps;

  @override
  void initState() {
    super.initState();
    _steps = [
      ClassSelectionStep(onNext: _nextPage),
      SubclassSelectionStep(onNext: _nextPage),
      AncestrySelectionStep(onNext: _nextPage),
      CommunitySelectionStep(onNext: _nextPage),
      AttributesStep(onNext: _nextPage),
      DomainCardsStep(onNext: _nextPage),
      EquipmentStep(onNext: _nextPage),
      BackgroundStep(onNext: _finishWizard),
    ];
  }

  void _nextPage() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _finishWizard() async {
    final newCharacter = ref.read(characterProvider);
    await StorageService.saveCharacter(newCharacter);

    if (!mounted) return;

    Navigator.of(context).pop(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${newCharacter.name} saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Creation - Step ${_currentStep + 1}/${_steps.length}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevPage,
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _steps,
      ),
    );
  }
}