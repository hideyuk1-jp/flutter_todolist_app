import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_todolist_app/Repositories/TaskRepositoryInterface.dart';
import 'package:flutter_todolist_app/Models/Task.dart';

class TaskRepository implements TaskRepositoryInterface {
  Future create(Task task) async {
    final tasks = Firestore.instance.collection('tasks');
    return tasks.add({
      'text': task.text,
      'dueDate': task.dueDate,
      'estimatedMinutes': task.estimatedMinutes,
      'completedAt': task.completedAt,
      'createdAt': task.createdAt,
      'updatedAt': task.updatedAt,
    });
  }

  Future<List<Task>> read() async {
    QuerySnapshot qs =
        await Firestore.instance.collection('tasks').getDocuments();
    return qs.documents.map((ds) => Task.fromSnapshot(ds)).toList();
  }

  Future update(Task task) async {
    return Firestore.instance
        .collection('tasks')
        .document(task.uuid)
        .updateData({
      'text': task.text,
      'dueDate': task.dueDate,
      'estimatedMinutes': task.estimatedMinutes,
      'completedAt': task.completedAt,
      'updatedAt': task.updatedAt,
    });
  }

  Future delete(Task task) async {
    return Firestore.instance.collection('tasks').document(task.uuid).delete();
  }
}
