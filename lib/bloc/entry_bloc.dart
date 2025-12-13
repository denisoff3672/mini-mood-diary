// lib/bloc/entry_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';
import '../repositories/mood_entries_repository.dart';
import 'entry_event.dart';
import 'entry_state.dart';

class EntryBloc extends Bloc<EntryEvent, EntryState> {
  final MoodEntriesRepository _repository;
  StreamSubscription<List<MoodEntry>>? _subscription;

  EntryBloc({required MoodEntriesRepository repository})
      : _repository = repository,
        super(const EntryInitial()) {

    on<LoadEntriesEvent>(_onLoadEntries);
    on<EntriesUpdatedEvent>(_onEntriesUpdated);
    on<UserChangedEvent>(_onUserChanged);

    // Ключова магія — слухаємо зміни авторизації глобально
    FirebaseAuth.instance.authStateChanges().listen((user) {
      add(UserChangedEvent(user: user));
    });
  }

  Future<void> _onUserChanged(UserChangedEvent event, Emitter<EntryState> emit) async {
    await _subscription?.cancel();
    if (event.user == null) {
      emit(const EntriesErrorState(error: 'Користувач не авторизований', entries: []));
    } else {
      add(const LoadEntriesEvent()); // автоматично завантажимо записи нового юзера
    }
  }

  Future<void> _onLoadEntries(LoadEntriesEvent event, Emitter<EntryState> emit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const EntriesErrorState(error: 'Користувач не авторизований', entries: []));
      return;
    }

    await _subscription?.cancel();
    emit(EntriesLoadingState(entries: state.entries));

    try {
      _subscription = _repository.getEntriesStream(user.uid).listen(
        (entries) => add(EntriesUpdatedEvent(entries: entries)),
        onError: (e) => emit(EntriesErrorState(error: e.toString(), entries: [])),
      );
    } catch (e) {
      emit(EntriesErrorState(error: e.toString(), entries: []));
    }
  }

  void _onEntriesUpdated(EntriesUpdatedEvent event, Emitter<EntryState> emit) {
    emit(EntriesLoadedState(entries: event.entries));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}