// lib/models/mood_entry.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MoodEntry extends Equatable {
  final String id;
  final String mood; 
  final String note;
  final DateTime date;
  final bool hasDetails; // Для демонстрації деталей
  final String userId; // Додано для ідентифікації власника

  const MoodEntry({
    required this.id,
    required this.mood,
    required this.note,
    required this.date,
    required this.userId, // Додано
    this.hasDetails = true,
  });

  @override
  List<Object?> get props => [id, mood, note, date, userId];

  String get dateString => '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  // === Методи для Firestore ===

  // Конвертація з Firestore DocumentSnapshot
  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      mood: data['mood'] as String,
      note: data['note'] as String,
      // Конвертація Timestamp у DateTime
      date: (data['date'] as Timestamp).toDate(), 
      userId: data['userId'] as String,
      hasDetails: data['hasDetails'] as bool? ?? true,
    );
  }

  // Конвертація в Map для запису в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'mood': mood,
      'note': note,
      // Зберігаємо як Timestamp
      'date': Timestamp.fromDate(date), 
      'userId': userId,
      'hasDetails': hasDetails,
    };
  }
  
  // Допоміжний метод для копіювання (для редагування)
  MoodEntry copyWith({
    String? id,
    String? mood,
    String? note,
    DateTime? date,
    String? userId,
    bool? hasDetails,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      hasDetails: hasDetails ?? this.hasDetails,
    );
  }
}