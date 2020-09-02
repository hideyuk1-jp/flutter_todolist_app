import 'package:intl/intl.dart';

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
    // 完了した時間が新しい順にソート
    tasks
        .sort((task1, task2) => task2.completedAt.compareTo(task1.completedAt));
    return tasks;
  }

  Future<List<Task>> getIncompletedTasks() async {
    List<Task> tasks = await getTasks();
    tasks = tasks.where((task) => task.completedAt == null).toList();
    tasks.sort((task1, task2) => task1.dueDate.compareTo(task2.dueDate));
    return tasks;
  }

  Future<Map<String, List<Task>>> getIncompletedTasksGroupedByDueDate() async {
    List<Task> tasks = await getIncompletedTasks();
    final today =
        DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    Map<String, List<Task>> tasksGroupedByDueDate = {};
    for (Task task in tasks) {
      String key = DateTime.parse(task.dueDate).isBefore(today)
          ? 'overdue'
          : task.dueDate;
      if (tasksGroupedByDueDate.containsKey(key))
        tasksGroupedByDueDate[key].add(task);
      else
        tasksGroupedByDueDate[key] = [task];
    }
    return tasksGroupedByDueDate;
  }

  Future<Map<String, List<Task>>>
      getCompletedTasksGroupedByCompleteDate() async {
    List<Task> tasks = await getCompletedTasks();
    Map<String, List<Task>> tasksGroupedByCompleteDate = {};
    for (Task task in tasks) {
      String key = DateFormat('yyyy-MM-dd').format(task.completedAt.toLocal());
      if (tasksGroupedByCompleteDate.containsKey(key))
        tasksGroupedByCompleteDate[key].add(task);
      else
        tasksGroupedByCompleteDate[key] = [task];
    }
    return tasksGroupedByCompleteDate;
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
    if (task.completedAt != null) {
      task.completedAt = null;
    } else {
      final now = DateTime.now();
      task.completedAt = now.toUtc();
    }
    await _taskRepository.update(task);
  }
}
