import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String uid;
  final bool completed;
  final String category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.uid,
    this.completed = false,
    this.category = 'Personal',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'uid': uid,
      'completed': completed,
      'category': category,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      uid: map['uid'] ?? '',
      completed: map['completed'] ?? false,
      category: map['category'] ?? 'Personal',
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? uid,
    bool? completed,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      uid: uid ?? this.uid,
      completed: completed ?? this.completed,
      category: category ?? this.category,
    );
  }
}