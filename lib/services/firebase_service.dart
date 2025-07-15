import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirebaseService {
  final CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    await _tasksCollection.add(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Stream<List<Task>> getUserTasks(String uid) {
    return _tasksCollection
        .where('uid', isEqualTo: uid)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<Task>> getTodayTasks(String uid) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return _tasksCollection
        .where('uid', isEqualTo: uid)
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dueDate', isLessThan: Timestamp.fromDate(end))
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<Map<String, dynamic>> getUserTaskStats(String uid) async {
    final completed = await _tasksCollection
        .where('uid', isEqualTo: uid)
        .where('completed', isEqualTo: true)
        .count()
        .get();

    final pending = await _tasksCollection
        .where('uid', isEqualTo: uid)
        .where('completed', isEqualTo: false)
        .count()
        .get();

    return {
      'completed': completed.count,
      'pending': pending.count,
    };
  }
}