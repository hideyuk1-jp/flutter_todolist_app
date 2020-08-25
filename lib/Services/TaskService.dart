import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_todolist_app/Repositories/TaskRepositoryInterface.dart';
import 'package:flutter_todolist_app/Services/TaskServiceInterface.dart';
import 'package:flutter_todolist_app/Models/Task.dart';

class TaskService implements TaskServiceInterface {
  final TaskRepositoryInterface _taskRepository;

  TaskService(this._taskRepository);

  Future<Task> getTaskByUuid(String uuid) async {
    List<Task> tasks = await _taskRepository.read();
    Task task = tasks.firstWhere((task) => task.uuid == uuid, orElse: null);
    return task;
  }

  Future<List<Task>> getTasks() async {
    List<Task> tasks = await _taskRepository.read();
    tasks.sort((task1, task2) => task1.createdAt.compareTo(task2.createdAt));
    return tasks;
  }

  Future<List<Task>> getCompletedTasks() async {
    List<Task> tasks = await getTasks();
    tasks = tasks.where((task) => task.completedAt != null).toList();
    tasks
        .sort((task1, task2) => task1.completedAt.compareTo(task2.completedAt));
    return tasks;
  }

  Future<List<Task>> getIncompletedTasks() async {
    List<Task> tasks = await getTasks();
    tasks = tasks.where((task) => task.completedAt == null).toList();
    return tasks;
  }

  // TODO: 未完成
  Future<Map<String, List<Task>>> getIncompletedTasksGroupedByDueDate() async {
    List<Task> tasks = await getIncompletedTasks();
    final now = DateTime.now();
    Map<String, List<Task>> tasksGroupedByDueDate = {};
    for (Task task in tasks) {
      for (int diff = 0; diff < 7; ++diff) {}
      DateTime dueDate = DateTime.parse(task.dueDate);
      print(now.difference(dueDate).inDays);
    }
    return tasksGroupedByDueDate;
  }

  Future create(String text, DateTime dueDate) async {
    final now = DateTime.now();
    Task task = new Task.fromMap({
      'uuid': Uuid().v4(),
      'text': text,
      'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
      'created_at': now.toUtc(),
      'updated_at': now.toUtc()
    });
    await _taskRepository.create(task);
  }

  Future update(String uuid, String text, DateTime dueDate) async {
    final now = DateTime.now();
    Task task = await getTaskByUuid(uuid);
    task.text = text;
    task.dueDate = DateFormat('yyyy-MM-dd').format(dueDate);
    task.updatedAt = now.toUtc();
    await _taskRepository.update(task);
  }

  Future delete(String uuid) async {
    Task task = await getTaskByUuid(uuid);
    await _taskRepository.delete(task);
  }

  Future toggleComplete(String uuid) async {
    Task task = await getTaskByUuid(uuid);
    if (task.completedAt != null) {
      task.completedAt = null;
    } else {
      final now = DateTime.now();
      task.completedAt = now.toUtc();
    }
    await _taskRepository.update(task);
  }
}
