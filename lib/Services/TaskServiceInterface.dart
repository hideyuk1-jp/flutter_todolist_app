import 'package:flutter_todolist_app/Models/Task.dart';

abstract class TaskServiceInterface {
  Future<Task> getTaskByUuid(String uuid);
  Future<List<Task>> getTasks();
  Future<List<Task>> getCompletedTasks();
  Future<List<Task>> getIncompletedTasks();
  Future<Map<String, List<Task>>> getIncompletedTasksGroupedByDueDate();
  Future create(String text, DateTime dueDate);
  Future update(String uuid, String text, DateTime dueDate);
  Future delete(String uuid);
  Future toggleComplete(String uuid);
}
