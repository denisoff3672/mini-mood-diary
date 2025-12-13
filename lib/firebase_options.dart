
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb; 

class DefaultFirebaseOptions {
 static FirebaseOptions get currentPlatform {
 if (kIsWeb) {
 return web;
}
 throw UnsupportedError('Firebase не налаштований для цієї платформи');
 }

 static const FirebaseOptions web = FirebaseOptions(
 apiKey: "AIzaSyBAo1a5H1lUOGDLipJnVvHyaT1KraYfoHo",
 authDomain: "mini-mood-diary.firebaseapp.com",
 projectId: "mini-mood-diary",
 storageBucket: "mini-mood-diary.firebasestorage.app",
 messagingSenderId: "809801474895",
 appId: "1:809801474895:web:eeebd9336d35d0c2e6db3a",
 measurementId: "G-VMKDX0PDE0"
 );
}