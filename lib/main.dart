// lib/main.dart
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mood_diary/services/firebase_service.dart';
import 'package:mini_mood_diary/pages/auth_page.dart';
import 'package:mini_mood_diary/core/app_strings.dart';
import 'package:mini_mood_diary/repositories/mood_entries_repository.dart';
import 'bloc/entry_bloc.dart';

const String _sentryDsn =
    'https://5d/f4b11464994cb620f1aacfa0a36ebc@o4510322665717760.ingest.de.sentry.io/4510322691342416';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();

  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.tracesSampleRate = 1.0;
      options.environment = 'web-development';
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MoodEntriesRepository>(
          create: (_) => FirestoreMoodEntriesRepository(),
        ),
      ],
      child: BlocProvider(
        create: (context) => EntryBloc(
          repository: RepositoryProvider.of<MoodEntriesRepository>(context),
        ),
        child: MaterialApp(
          title: AppStrings.appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const AuthPage(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}