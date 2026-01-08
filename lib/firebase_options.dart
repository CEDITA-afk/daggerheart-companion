// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // --- CONFIGURAZIONE WEB (Quella che serve per GitHub Pages) ---
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDA5fHTWbjOfnH98nfXAt3id2gO1eZKZcs",
    authDomain: "daggerheart-companion.firebaseapp.com",
     projectId: "daggerheart-companion",
     storageBucket: "daggerheart-companion.firebasestorage.app",
     messagingSenderId: "92151231740",
     appId: "1:92151231740:web:c90f4d68223ab30b955379",
      measurementId: "G-989TVVFE74"
  );

  // --- CONFIGURAZIONE ANDROID (Opzionale se usi solo Web per ora) ---
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'INCOLLA_API_KEY_ANDROID',
    appId: 'INCOLLA_APP_ID_ANDROID',
    messagingSenderId: '...',
    projectId: '...',
    storageBucket: '...',
  );
  
  // Lascia iOS vuoto o dummy se non lo usi
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '...',
    appId: '...',
    messagingSenderId: '...',
    projectId: '...',
    storageBucket: '...',
    iosBundleId: 'com.example.app',
  );
}