import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/repositories/task_repository_interface.dart';
import 'package:flutter_todolist_app/models/task.dart';

final taskRepository = Provider.autoDispose<TaskRepositoryInterface>(
    (ref) => TaskRepository(ref.read));

class TaskRepository implements TaskRepositoryInterface {
  final Reader read;
  final _tasksReference = Firestore.instance.collection('tasks');

  TaskRepository(this.read);

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

  CollectionReference ref() {
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
