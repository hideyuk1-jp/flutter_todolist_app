import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_todolist_app/Repositories/TaskRepositoryInterface.dart';
import 'package:flutter_todolist_app/Models/Task.dart';

class TaskRepository implements TaskRepositoryInterface {
  static final tasksKey = 'tasks';

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getString(tasksKey);
    if (items == null) return <Task>[];
    List<Map<String, dynamic>> jsonArray =
        json.decode(items).cast<Map<String, dynamic>>();
    List<Task> tasks =
        jsonArray.map<Task>((task) => new Task.fromJson(task)).toList();
    return tasks;
  }

  Future saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(tasksKey, json.encode(tasks));
  }

  Future create(Task task) async {
    List<Task> tasks = await read();
    tasks.add(task);
    saveTasks(tasks);
  }

  Future<List<Task>> read() async {
    return await loadTasks();
  }

  Future update(Task task) async {
    List<Task> tasks = await read();
    tasks.removeWhere((item) => item.uuid == task.uuid);
    tasks.add(task);
    saveTasks(tasks);
  }

  Future delete(Task task) async {
    List<Task> tasks = await read();
    tasks.removeWhere((item) => item.uuid == task.uuid);
    saveTasks(tasks);
  }
}
