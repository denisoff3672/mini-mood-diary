

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry.dart';


export 'mood_entries_repository.dart';


abstract class MoodEntriesRepository {
  Stream<List<MoodEntry>> getEntriesStream(String userId);
  Future<void> addEntry(MoodEntry entry);
  Future<void> updateEntry(MoodEntry entry);
  Future<void> deleteEntry(String entryId, String userId);
}


class FirestoreMoodEntriesRepository implements MoodEntriesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _entriesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('entries');
  }

  @override
  Stream<List<MoodEntry>> getEntriesStream(String userId) {
    return _entriesCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoodEntry.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> addEntry(MoodEntry entry) async {
    await _entriesCollection(entry.userId).add(entry.toFirestore());
  }

  @override
  Future<void> updateEntry(MoodEntry entry) async {
    await _entriesCollection(entry.userId)
        .doc(entry.id)
        .update(entry.toFirestore());
  }

  @override
  Future<void> deleteEntry(String entryId, String userId) async {
    await _entriesCollection(userId).doc(entryId).delete();
  }
}