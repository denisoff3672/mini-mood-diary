// lib/pages/add_entry_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bloc/add_edit_entry_bloc.dart';
import '../bloc/add_edit_entry_event.dart';
import '../bloc/add_edit_entry_state.dart';
import '../core/app_strings.dart';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({super.key});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  String? mood;
  final TextEditingController noteController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _saveEntry(BuildContext context) {
    if (mood == null || noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Заповніть усі поля")),
      );
      return;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Помилка авторизації. Перезайдіть.")),
      );
      return;
    }

    context.read<AddEditEntryBloc>().add(
          CreateEntryEvent(
            mood: mood!,
            note: noteController.text.trim(),
            userId: currentUser!.uid,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddEditEntryBloc, AddEditEntryState>(
      listener: (context, state) {
        if (state is AddEditEntrySuccessState) {
          noteController.clear();
          setState(() => mood = null);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Запис успішно створено!"),
              backgroundColor: Colors.green,
            ),
          );

          // Автоматично закриваємо сторінку після збереження
          if (mounted) Navigator.of(context).pop();
        } else if (state is AddEditEntryErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AddEditEntryBloc, AddEditEntryState>(
        builder: (context, state) {
          final isLoading = state is AddEditEntryLoadingState;

          return Scaffold(
            appBar: AppBar(
              title: const Text(AppStrings.addEntryTitle),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Додати новий запис',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  DropdownButtonFormField<String>(
                    value: mood,
                    decoration: const InputDecoration(
                      labelText: 'Настрій',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Добрий', child: Text('Добрий')),
                      DropdownMenuItem(value: 'Нормальний', child: Text('Нормальний')),
                      DropdownMenuItem(value: 'Поганий', child: Text('Поганий')),
                    ],
                    onChanged: isLoading ? null : (value) => setState(() => mood = value),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: noteController,
                    enabled: !isLoading,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Нотатка',
                      hintText: 'Що сталося сьогодні?..',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _saveEntry(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Зберегти', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}