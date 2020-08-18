import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'task.dart';

class SharedPref {
  static final tasksKey = 'tasks';

  //---------- Task ----------
  readTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getString(tasksKey);
    if (items == null) return <Task>[];
    List<Map<String, dynamic>> jsonArray =
        json.decode(items).cast<Map<String, dynamic>>();
    List<Task> tasks =
        jsonArray.map<Task>((task) => new Task.fromJson(task)).toList();
    print(json.encode(tasks));
    return tasks;
  }

  createTask(Task task) async {
    final now = DateTime.now();
    var uuid = Uuid();
    List<Task> tasks = await readTasks();
    task.uuid = uuid.v1();
    task.createdAt = now.toUtc();
    task.updatedAt = now.toUtc();
    tasks.add(task);
    await saveTasks(tasks);
  }

  saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(tasksKey, json.encode(tasks));
  }

  editTask(Task task) async {
    final now = DateTime.now();
    List<Task> tasks = await readTasks();
    task.updatedAt = now.toUtc();
    tasks.removeWhere((item) => item.uuid == task.uuid);
    tasks.add(task);
    await saveTasks(tasks);
  }

  deleteTask(Task task) async {
    List<Task> tasks = await readTasks();
    tasks.removeWhere((item) => item.uuid == task.uuid);
    await saveTasks(tasks);
  }
}
