// lib/pages/mood_diary_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Додано
import 'package:mini_mood_diary/services/firebase_service.dart';
import '../repositories/mood_entries_repository.dart'; // Додано
import '../bloc/add_edit_entry_bloc.dart'; // Додано
import 'add_entry_page.dart';
import 'entries_list_page.dart';
import 'statistics_page.dart';
import 'auth_page.dart';

class MoodDiaryPage extends StatefulWidget {
  final String name;
  final String surname;
  final String email;

  const MoodDiaryPage({
    super.key,
    required this.name,
    required this.surname,
    required this.email,
  });

  @override
  State<MoodDiaryPage> createState() => _MoodDiaryPageState();
}

class _MoodDiaryPageState extends State<MoodDiaryPage> {
  int _selectedIndex = 0;
  // Локальні _entries більше не потрібні
  // final List<Map<String, dynamic>> _entries = []; 
  final FirebaseService _firebaseService = FirebaseService.instance;

  void _onTabTapped(int index) => setState(() => _selectedIndex = index);
  
  
  void _logout() async {
    await _firebaseService.signOut(); 
    if (!mounted) return;
    
    // Перехід на сторінку авторизації
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Отримуємо репозиторій з RepositoryProvider
    final MoodEntriesRepository moodEntriesRepository = RepositoryProvider.of<MoodEntriesRepository>(context); 
    
    // Створюємо список сторінок, обертаючи AddEntryPage у BlocProvider
    final pages = [
      BlocProvider( 
        create: (context) => AddEditEntryBloc(repository: moodEntriesRepository),
        child: const AddEntryPage(), // Більше не передаємо entries
      ),
      const EntriesListPage(), // Більше не передаємо entries
      const StatisticsPage(), // Більше не передаємо entries
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Привіт, ${widget.name} ${widget.surname}! 👋",
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.red),
            tooltip: 'Тест Sentry',
            onPressed: () {
              
              _firebaseService.forceCrash(); 
            },
          ),
          
          
          
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Вийти',
            onPressed: _logout, // Викликаємо метод виходу
          )
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.add), label: "Додати запис"),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: "Мої записи"),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: "Статистика"),
        ],
      ),
    );
  }
}