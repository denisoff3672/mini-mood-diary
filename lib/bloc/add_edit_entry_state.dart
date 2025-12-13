// lib/bloc/add_edit_entry_state.dart
import 'package:equatable/equatable.dart';

abstract class AddEditEntryState extends Equatable {
  const AddEditEntryState();

  @override
  List<Object> get props => [];
}

class AddEditEntryInitialState extends AddEditEntryState {}

class AddEditEntryLoadingState extends AddEditEntryState {}

/// Успіх з повідомленням — щоб показувати тости і точно знати, що операція завершилась
class AddEditEntrySuccessState extends AddEditEntryState {
  final String message;
  const AddEditEntrySuccessState([this.message = 'Успішно збережено!']);

  @override
  List<Object> get props => [message];
}

class AddEditEntryErrorState extends AddEditEntryState {
  final String message;
  const AddEditEntryErrorState(this.message);

  @override
  List<Object> get props => [message];
}