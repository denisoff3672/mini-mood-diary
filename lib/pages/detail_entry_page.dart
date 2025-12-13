// lib/pages/detail_entry_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/mood_entry.dart';
import '../core/app_strings.dart';
import '../bloc/add_edit_entry_bloc.dart';
import '../bloc/add_edit_entry_event.dart';
import '../bloc/add_edit_entry_state.dart';

class DetailEntryPage extends StatefulWidget {
  final MoodEntry entry;
  const DetailEntryPage({super.key, required this.entry});

  @override
  State<DetailEntryPage> createState() => _DetailEntryPageState();
}

class _DetailEntryPageState extends State<DetailEntryPage> {
  late String _currentMood;
  late TextEditingController _noteController;
  late bool _isEditing;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _currentMood = widget.entry.mood;
    _noteController = TextEditingController(text: widget.entry.note);
    _isEditing = false;
  }

  void _toggleEdit() => setState(() => _isEditing = !_isEditing);

  void _saveChanges() {
    if (_noteController.text.trim().isEmpty || currentUser == null) return;

    final updatedEntry = widget.entry.copyWith(
      mood: _currentMood,
      note: _noteController.text.trim(),
    );

    context.read<AddEditEntryBloc>().add(UpdateEntryEvent(entry: updatedEntry));
  }

  void _deleteEntry() {
    if (currentUser == null) return;

    context.read<AddEditEntryBloc>().add(
      DeleteEntryEvent(entryId: widget.entry.id, userId: currentUser!.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddEditEntryBloc, AddEditEntryState>(
      listener: (context, state) {
        if (state is AddEditEntrySuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Зміни збережено!"),
              backgroundColor: Colors.green,
            ),
          );

          setState(() => _isEditing = false);

          // Якщо це було видалення — закриваємо сторінку
          if (state is AddEditEntrySuccessState && mounted) {
            Navigator.pop(context);
          }
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
              title: Text(_isEditing ? 'Редагування запису' : '${widget.entry.mood} - ${widget.entry.dateString}'),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              actions: [
                if (!_isEditing)
                  IconButton(icon: const Icon(Icons.edit), onPressed: isLoading ? null : _toggleEdit, tooltip: 'Редагувати'),
                if (_isEditing)
                  IconButton(icon: const Icon(Icons.save), onPressed: isLoading ? null : _saveChanges, tooltip: 'Зберегти'),
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    onPressed: isLoading ? null : _deleteEntry,
                    tooltip: 'Видалити',
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Настрій', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      _isEditing
                          ? DropdownButton<String>(
                              value: _currentMood,
                              items: ["Добрий", "Нормальний", "Поганий"]
                                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                  .toList(),
                              onChanged: isLoading ? null : (v) => setState(() => _currentMood = v!),
                            )
                          : Text(widget.entry.mood, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    ],
                  ),
                  const Divider(height: 30),

                  const Text('Нотатка', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepPurple.shade100),
                    ),
                    child: _isEditing
                        ? TextField(
                            controller: _noteController,
                            enabled: !isLoading,
                            maxLines: 5,
                            decoration: const InputDecoration.collapsed(hintText: 'Введіть нотатку'),
                          )
                        : Text(widget.entry.note, style: const TextStyle(fontSize: 16, height: 1.5)),
                  ),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: LinearProgressIndicator()),
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
    _noteController.dispose();
    super.dispose();
  }
}