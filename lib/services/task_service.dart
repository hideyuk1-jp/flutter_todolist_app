import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/repositories/task_repository.dart';
import 'package:flutter_todolist_app/services/task_service_interface.dart';
import 'package:flutter_todolist_app/models/task.dart';

final taskService =
    Provider.autoDispose<TaskServiceInterface>((ref) => TaskService(ref.read));

class TaskService implements TaskServiceInterface {
  final Reader read;

  TaskService(this.read);

  Future<Task> getTaskByUuid(String uuid) async {
    DocumentSnapshot doc =
        await read(taskRepository).ref().document(uuid).get();
    Task task = Task.fromSnapshot(doc);
    return task;
  }

  Stream<List<Task>> getTasks() {
    return read(taskRepository).ref().snapshots().asyncMap((snapshot) =>
        snapshot.documents.map<Task>((doc) => Task.fromSnapshot(doc)).toList());
  }

  Stream<List<Task>> getDones() {
    return read(taskRepository)
        .ref()
        .orderBy('completedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) {
      List<Task> tasks = [];
      snapshot.documents.forEach((doc) {
        if (doc['completedAt'] != null) tasks.add(Task.fromSnapshot(doc));
      });
      return tasks;
    });
  }

  Stream<List<Task>> getTodos() {
    return read(taskRepository)
        .ref()
        .where('completedAt', isNull: true)
        .orderBy('dueDate')
        .orderBy('createdAt')
        .snapshots()
        .asyncMap((snapshot) => snapshot.documents
            .map<Task>((doc) => Task.fromSnapshot(doc))
            .toList());
  }

  Future create(String text, DateTime dueDate, int estimatedMinutes) async {
    final now = DateTime.now();
    Task task = new Task.fromMap({
      'text': text,
      'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
      'estimated_minutes': estimatedMinutes,
      'created_at': now.toUtc(),
      'updated_at': now.toUtc()
    });
    await read(taskRepository).create(task);
  }

  Future update(
      String uuid, String text, DateTime dueDate, int estimatedMinutes) async {
    final now = DateTime.now();
    Task task = await getTaskByUuid(uuid);
    task.text = text;
    task.dueDate = DateFormat('yyyy-MM-dd').format(dueDate);
    task.estimatedMinutes = estimatedMinutes;
    task.updatedAt = now.toUtc();
    await read(taskRepository).update(task);
  }

  Future delete(String uuid) async {
    Task task = await getTaskByUuid(uuid);
    await read(taskRepository).delete(task);
  }

  Future toggleComplete(String uuid) async {
    Task task = await getTaskByUuid(uuid);
    final now = DateTime.now();
    if (task.completedAt != null) {
      task.completedAt = null;
    } else {
      task.completedAt = now.toUtc();
    }
    task.updatedAt = now.toUtc();
    await read(taskRepository).update(task);
  }
}
