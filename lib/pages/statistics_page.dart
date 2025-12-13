// lib/pages/statistics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/mood_chart.dart';
import '../bloc/entry_bloc.dart';
import '../bloc/entry_state.dart';


class StatisticsPage extends StatelessWidget {
  // Список entries більше не потрібен у конструкторі
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EntryBloc, EntryState>(
      builder: (context, state) {
        if (state is EntriesLoadingState && state.entries.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
        }

        // Помилка виникала через те, що MoodChart очікував List<Map<String, dynamic>>, 
        // але тепер ми його оновили, і він приймає List<MoodEntry> (state.entries)
        if (state.entries.isEmpty) {
          return const Center(child: Text("Недостатньо даних для статистики 😔"));
        }
        
        // Передаємо список MoodEntry у MoodChart
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MoodChart(entries: state.entries),
          ),
        );
      },
    );
  }
}