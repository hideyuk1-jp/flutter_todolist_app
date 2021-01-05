import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todolist_app/models/user.dart';
import 'package:flutter_todolist_app/user_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/repositories/task_repository_interface.dart';
import 'package:flutter_todolist_app/models/task.dart';

final taskRepository = Provider.autoDispose<TaskRepositoryInterface>(
    (ref) => TaskRepository(ref.read));

class TaskRepository implements TaskRepositoryInterface {
  final Reader read;

  TaskRepository(this.read);

  Future create(Task task) async {
    return this.ref().add({
      'text': task.text,
      'dueDate': task.dueDate,
      'estimatedMinutes': task.estimatedMinutes,
      'completedAt': task.completedAt,
      'createdAt': task.createdAt,
      'updatedAt': task.updatedAt,
    });
  }

  CollectionReference ref() {
    User user = read(userViewModelProvider).user;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('tasks');
  }

  Future update(Task task) async {
    return this.ref().doc(task.uuid).update({
      'text': task.text,
      'dueDate': task.dueDate,
      'estimatedMinutes': task.estimatedMinutes,
      'completedAt': task.completedAt,
      'updatedAt': task.updatedAt,
    });
  }

  Future delete(Task task) async {
    return this.ref().doc(task.uuid).delete();
  }
}
