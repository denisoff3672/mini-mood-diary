// lib/bloc/add_edit_entry_event.dart
import 'package:equatable/equatable.dart';
import '../models/mood_entry.dart';

abstract class AddEditEntryEvent extends Equatable {
  const AddEditEntryEvent();

  @override
  List<Object> get props => [];
}

class CreateEntryEvent extends AddEditEntryEvent {
  final String mood;
  final String note;
  final String userId;

  const CreateEntryEvent({required this.mood, required this.note, required this.userId});

  @override
  List<Object> get props => [mood, note, userId];
}

class UpdateEntryEvent extends AddEditEntryEvent {
  final MoodEntry entry;

  const UpdateEntryEvent({required this.entry});

  @override
  List<Object> get props => [entry];
}

class DeleteEntryEvent extends AddEditEntryEvent {
  final String entryId;
  final String userId;

  const DeleteEntryEvent({required this.entryId, required this.userId});

  @override
  List<Object> get props => [entryId, userId];
}