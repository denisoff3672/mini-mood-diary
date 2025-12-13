// lib/bloc/entry_state.dart
import 'package:equatable/equatable.dart';
import '../models/mood_entry.dart';

abstract class EntryState extends Equatable {
  final List<MoodEntry> entries;
  const EntryState({required this.entries});
  @override
  List<Object> get props => [entries];
}

class EntryInitial extends EntryState {
  const EntryInitial() : super(entries: const []);
}

class EntriesLoadingState extends EntryState {
  const EntriesLoadingState({required super.entries});
}

class EntriesLoadedState extends EntryState {
  const EntriesLoadedState({required super.entries});
}

class EntriesErrorState extends EntryState {
  final String error;
  const EntriesErrorState({required this.error, required super.entries});
  @override
  List<Object> get props => [entries, error];
}