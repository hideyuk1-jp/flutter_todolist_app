import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_todolist_app/repositories/task_repository_interface.dart';
import 'package:flutter_todolist_app/services/task_service_interface.dart';
import 'package:flutter_todolist_app/models/task.dart';

class TaskService implements TaskServiceInterface {
  final TaskRepositoryInterface _taskRepository;

  TaskService(this._taskRepository);

  Future<Task> getTaskByUuid(String uuid) async {
    DocumentSnapshot doc = await _taskRepository.read().document(uuid).get();
    Task task = Task.fromSnapshot(doc);
    return task;
  }

  Stream<List<Task>> getTasks() {
    return _taskRepository.read().snapshots().asyncMap((snapshot) =>
        snapshot.documents.map<Task>((doc) => Task.fromSnapshot(doc)).toList());
  }

  Stream<List<Task>> getCompletedTasks() {
    return _taskRepository
        .read()
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

  Stream<List<Task>> getIncompletedTasks() {
    return _taskRepository
        .read()
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
    await _taskRepository.create(task);
  }

  Future update(
      String uuid, String text, DateTime dueDate, int estimatedMinutes) async {
    final now = DateTime.now();
    Task task = await getTaskByUuid(uuid);
    task.text = text;
    task.dueDate = DateFormat('yyyy-MM-dd').format(dueDate);
    task.estimatedMinutes = estimatedMinutes;
    task.updatedAt = now.toUtc();
    await _taskRepository.update(task);
  }

  Future delete(String uuid) async {
    Task task = await getTaskByUuid(uuid);
    await _taskRepository.delete(task);
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
    await _taskRepository.update(task);
  }
}
