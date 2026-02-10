import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/data_repository.dart'; // Import necessario per il caricamento
import 'screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: DaggerheartApp(),
    ),
  );
}

// Trasformiamo in ConsumerWidget per ascoltare il caricamento dati
class DaggerheartApp extends ConsumerWidget {
  const DaggerheartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ASCOLTA IL CARICAMENTO DATI
    // Questo avvia la lettura dei JSON all'avvio dell'app
    final dataLoader = ref.watch(dataLoaderFuture);

    return MaterialApp(
      title: 'Daggerheart Creator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // GESTIONE STATI DI CARICAMENTO
      home: dataLoader.when(
        // Se i dati sono pronti -> Mostra la Home
        data: (_) => const HomeScreen(),
        
        // Se sta caricando -> Mostra rotellina al centro
        loading: () => const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Loading Rules & Content..."),
              ],
            ),
          ),
        ),
        
        // Se c'è un errore (es. JSON malformato) -> Mostra l'errore
        error: (err, stack) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Error loading data:\n$err",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}