// lib/bloc/add_edit_entry_bloc.dart
import 'package:bloc/bloc.dart';
import '../models/mood_entry.dart';
import '../repositories/mood_entries_repository.dart';
import 'add_edit_entry_event.dart';
import 'add_edit_entry_state.dart';

class AddEditEntryBloc extends Bloc<AddEditEntryEvent, AddEditEntryState> {
  final MoodEntriesRepository _repository;

  AddEditEntryBloc({required MoodEntriesRepository repository})
      : _repository = repository,
        super(AddEditEntryInitialState()) {
    on<CreateEntryEvent>(_onCreateEntry);
    on<UpdateEntryEvent>(_onUpdateEntry);
    on<DeleteEntryEvent>(_onDeleteEntry);
  }

  Future<void> _onCreateEntry(CreateEntryEvent event, Emitter<AddEditEntryState> emit) async {
    emit(AddEditEntryLoadingState());
    try {
      final newEntry = MoodEntry(
        id: '',
        mood: event.mood,
        note: event.note.trim(),
        date: DateTime.now(),
        userId: event.userId,
      );

      await _repository.addEntry(newEntry);
      emit(const AddEditEntrySuccessState('Запис успішно додано!'));
    } catch (e) {
      emit(AddEditEntryErrorState('Помилка при додаванні: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateEntry(UpdateEntryEvent event, Emitter<AddEditEntryState> emit) async {
    emit(AddEditEntryLoadingState());
    try {
      await _repository.updateEntry(event.entry);
      emit(const AddEditEntrySuccessState('Зміни успішно збережено!'));
    } catch (e) {
      emit(AddEditEntryErrorState('Помилка при оновленні: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteEntry(DeleteEntryEvent event, Emitter<AddEditEntryState> emit) async {
    emit(AddEditEntryLoadingState());
    try {
      await _repository.deleteEntry(event.entryId, event.userId);
      emit(const AddEditEntrySuccessState('Запис успішно видалено!'));
    } catch (e) {
      emit(AddEditEntryErrorState('Помилка при видаленні: ${e.toString()}'));
    }
  }
}