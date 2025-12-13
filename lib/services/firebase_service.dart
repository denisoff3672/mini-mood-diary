// lib/services/firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';


class FirebaseService {
 
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  
  late final FirebaseAuth auth;
  late final FirebaseAnalytics analytics;

  
  Future<void> init() async {
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    
    auth = FirebaseAuth.instance;
    analytics = FirebaseAnalytics.instance;

    

    
    FlutterError.onError = (FlutterErrorDetails details) {
      
      FlutterError.presentError(details);
      
      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
      );
    };

   
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      Sentry.captureException(error, stackTrace: stack);
      return true; // Помилка оброблена
    };
  }

  // ==============================================================
  // АВТОРИЗАЦІЯ
  // ==============================================================

  /// Вхід користувача
  Future<String?> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Логування події входу
      await analytics.logLogin(loginMethod: 'email');
      return null; // Успіх
    } on FirebaseAuthException catch (e) {
      await _reportToSentry(e, e.stackTrace);

      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Неправильний email або пароль';
        case 'invalid-email':
          return 'Невірний формат email';
        default:
          return 'Помилка входу';
      }
    } catch (e, st) {
      await _reportToSentry(e, st);
      return 'Невідома помилка';
    }
  }

  /// Реєстрація користувача
  Future<String?> register(
    String name,
    String surname,
    String email,
    String password,
  ) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      
      await userCredential.user?.updateDisplayName('$name $surname');

      
      await analytics.logEvent(
        name: 'sign_up',
        parameters: {'method': 'email'},
      );

      return null; 
    } on FirebaseAuthException catch (e) {
      await _reportToSentry(e, e.stackTrace);

      switch (e.code) {
        case 'weak-password':
          return 'Пароль занадто слабкий (мін. 6 символів)';
        case 'email-already-in-use':
          return 'Користувач з таким email вже існує';
        case 'invalid-email':
          return 'Невірний формат email';
        default:
          return 'Помилка реєстрації';
      }
    } catch (e, st) {
      await _reportToSentry(e, st);
      return 'Невідома помилка';
    }
  }

  /// Вихід користувача
  Future<void> signOut() async {
    await auth.signOut();
  }



  /// Логування події в Analytics
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    try {
      await analytics.logEvent(name: name, parameters: params);
    } catch (_) {
      
    }
  }

  /// Тестовий краш 
  void forceCrash() {
    Sentry.captureMessage('Force crash invoked');

    
    Future.microtask(() {
      throw StateError('Forced crash for Sentry testing');
    });
  }

  
  Future<void> _reportToSentry(Object error, StackTrace? stackTrace) async {
    await Sentry.captureException(error, stackTrace: stackTrace);
  }
}