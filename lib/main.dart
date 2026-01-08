import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// IMPORTA IL FILE APPENA CREATO
import 'firebase_options.dart'; 

// ... import dei provider ...
import 'logic/creation_provider.dart';
import 'logic/combat_provider.dart';
import 'logic/room_provider.dart';
import 'logic/gm_provider.dart';
import 'data/data_manager.dart';
import 'ui/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await DataManager().loadAllData();

  try {
    // Inizializza usando il file firebase_options.dart
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase connesso!");
  } catch (e) {
    print("ERRORE FIREBASE: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CreationProvider()),
        ChangeNotifierProvider(create: (_) => CombatProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => GmProvider()),
      ],
      child: MaterialApp(
        title: 'Daggerheart Companion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFFD4AF37),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            secondary: Colors.amberAccent,
            surface: Color(0xFF1E1E1E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontFamily: 'Lato', color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.grey),
          ),
        ),
        // Qui impostiamo la nuova schermata di benvenuto come punto di partenza
        home: const WelcomeScreen(),
      ),
    );
  }
}