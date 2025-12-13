// lib/bloc/entry_event.dart
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';

abstract class EntryEvent extends Equatable {
  const EntryEvent();
  @override
  List<Object?> get props => [];
}

class LoadEntriesEvent extends EntryEvent {
  const LoadEntriesEvent();
}

class EntriesUpdatedEvent extends EntryEvent {
  final List<MoodEntry> entries;
  const EntriesUpdatedEvent({required this.entries});
  @override
  List<Object?> get props => [entries];
}

class UserChangedEvent extends EntryEvent {
  final User? user;
  const UserChangedEvent({required this.user});
  @override
  List<Object?> get props => [user];
}