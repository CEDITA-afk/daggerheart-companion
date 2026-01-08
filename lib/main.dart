import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'logic/creation_provider.dart';
import 'logic/combat_provider.dart';
import 'logic/room_provider.dart';
import 'logic/gm_provider.dart';
import 'data/data_manager.dart';
import 'ui/screens/startup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager().loadAllData();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print("Errore Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALETTE DAGGERHEART ---
    const dhGold = Color(0xFFCFB876);        // Oro spento/Pergamena
    const dhGoldBright = Color(0xFFF4D03F);  // Oro brillante (accenti)
    const dhBackground = Color(0xFF1A1625);  // Viola scurissimo (quasi nero)
    const dhSurface = Color(0xFF2A2438);     // Viola scuro (card/dialog)
    const dhPurpleAccent = Color(0xFF6A4C93); // Viola medio

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => CreationProvider()),
        ChangeNotifierProvider(create: (_) => CombatProvider()),
        ChangeNotifierProvider(create: (_) => GmProvider()),
      ],
      child: MaterialApp(
        title: 'Daggerheart Companion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: dhBackground,
          primaryColor: dhGold,
          
          colorScheme: const ColorScheme.dark(
            primary: dhGold,
            onPrimary: Colors.black, // Testo nero su bottoni oro
            secondary: dhPurpleAccent,
            surface: dhSurface,
            onSurface: Colors.white,
            error: Color(0xFFCF6679),
          ),
          
          // Testi
          textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme).apply(
            bodyColor: const Color(0xFFE0E0E0), // Bianco sporco per leggibilità
            displayColor: dhGold,
          ),
          
          // AppBar
          appBarTheme: const AppBarTheme(
            backgroundColor: dhBackground,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Cinzel', 
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: dhGold
            ),
            iconTheme: IconThemeData(color: dhGold),
          ),
          
          // Bottoni
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: dhGold,
              foregroundColor: Colors.black, // Testo scuro su oro
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cinzel'),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: dhGold,
              side: const BorderSide(color: dhGold),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          
          // Input
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: dhSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: dhPurpleAccent.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: dhGold),
            ),
            labelStyle: const TextStyle(color: Colors.white60),
            hintStyle: const TextStyle(color: Colors.white30),
          ),
          
          // CORREZIONE QUI: Usa CardThemeData invece di CardTheme
          cardTheme: CardThemeData(
            color: dhSurface,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: dhGold.withOpacity(0.1)), // Sottile bordo oro
            ),
          ),
          
          // CORREZIONE QUI: Usa DialogThemeData invece di DialogTheme
          dialogTheme: DialogThemeData(
            backgroundColor: dhSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: dhGold, width: 2), // Bordo oro nei dialoghi
            ),
            titleTextStyle: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 20,
              color: dhGold,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        home: const StartupScreen(),
      ),
    );
  }
}