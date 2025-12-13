// lib/pages/entries_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/entry_bloc.dart';
import '../bloc/entry_event.dart';
import '../bloc/entry_state.dart';
import '../repositories/mood_entries_repository.dart'; // Додано
import '../bloc/add_edit_entry_bloc.dart'; // Додано
import 'detail_entry_page.dart';

class EntriesListPage extends StatefulWidget {
  // Локальний список entries видалено
  const EntriesListPage({super.key});

  @override
  State<EntriesListPage> createState() => _EntriesListPageState();
}

class _EntriesListPageState extends State<EntriesListPage> {
  
  @override
  void initState() {
    super.initState();
    // BLoC вже викликається у main.dart, але тут можна додати повторний виклик, 
    // якщо треба оновити дані вручну (зараз Stream робить це автоматично)
    // context.read<EntryBloc>().add(const LoadEntriesEvent());
  }
  
  @override
  Widget build(BuildContext context) {
    // Отримуємо репозиторій для передачі в AddEditEntryBloc на екрані деталей
    final moodEntriesRepository = RepositoryProvider.of<MoodEntriesRepository>(context);

    // BlocBuilder слугує для реактивного оновлення інтерфейсу при зміні стану BLoC
    return BlocBuilder<EntryBloc, EntryState>(
      builder: (context, state) {
        
        // --- 1. Обробка стану завантаження (Loading State) ---
        if (state is EntriesLoadingState) {
          // Якщо список пустий і це завантаження, показуємо спінер
          if (state.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }
        }

        // --- 2. Обробка стану помилки (Error State) ---
        if (state is EntriesErrorState && state.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                // Виведення повідомлення про помилку з BLoC
                Text(state.error, style: const TextStyle(fontSize: 18, color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                // Кнопка для повторної спроби (повторний виклик LoadEntriesEvent)
                ElevatedButton.icon(
                  onPressed: () => context.read<EntryBloc>().add(const LoadEntriesEvent()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Спробувати знову'),
                ),
              ],
            ),
          );
        }

        // --- 3. Обробка стану порожнього списку ---
        if (state.entries.isEmpty) {
          return const Center(child: Text("Поки що немає записів 😔"));
        }

        // --- 4. Обробка успішного стану (Loaded State) ---
        
        // Відображення списку (ListView)
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: state.entries.length,
          itemBuilder: (context, index) {
            final entry = state.entries[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              elevation: 4,
              child: ListTile(
                leading: _getMoodIcon(entry.mood),
                title: Text(entry.mood, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                subtitle: Text("${entry.note}\n${entry.dateString}"),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                    // Навігація до екрана деталей (з можливістю редагування/видалення)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => 
                          // Обгортаємо DetailEntryPage в AddEditEntryBloc для операцій
                          BlocProvider( 
                            create: (_) => AddEditEntryBloc(repository: moodEntriesRepository),
                            child: DetailEntryPage(entry: entry),
                          ),
                      ),
                    );
                  },
              ),
            );
          },
        );
      },
    );
  }
  
  // Допоміжна функція для іконок настрою
  Widget _getMoodIcon(String mood) {
    switch (mood) {
      case 'Добрий':
        return const Icon(Icons.sentiment_very_satisfied, color: Colors.green, size: 30);
      case 'Нормальний':
        return const Icon(Icons.sentiment_neutral, color: Colors.orange, size: 30);
      case 'Поганий':
        return const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red, size: 30);
      default:
        return const Icon(Icons.help);
    }
  }
}