import 'package:flutter_todolist_app/Models/Task.dart';

abstract class TaskRepositoryInterface {
  Future<List<Task>> loadTasks();
  Future saveTasks(List<Task> tasks);
  Future create(Task task);
  Future<List<Task>> read();
  Future update(Task task);
  Future delete(Task task);
}
