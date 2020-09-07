import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_todolist_app/repositories/task_repository_interface.dart';
import 'package:flutter_todolist_app/models/task.dart';

class TaskRepository implements TaskRepositoryInterface {
  final _tasksReference = Firestore.instance.collection('tasks');

  Future create(Task task) async {
    return _tasksReference.add({
      'text': task.text,
      'dueDate': task.dueDate,
      'estimatedMinutes': task.estimatedMinutes,
      'completedAt': task.completedAt,
      'createdAt': task.createdAt,
      'updatedAt': task.updatedAt,
    });
  }

  CollectionReference read() {
    return _tasksReference;
  }

  Future update(Task task) async {
    return _tasksReference.document(task.uuid).updateData({
      'text': task.text,
      'dueDate': task.dueDate,
      'estimatedMinutes': task.estimatedMinutes,
      'completedAt': task.completedAt,
      'updatedAt': task.updatedAt,
    });
  }

  Future delete(Task task) async {
    return _tasksReference.document(task.uuid).delete();
  }
}
