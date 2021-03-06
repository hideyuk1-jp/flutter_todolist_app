import 'package:flutter_todolist_app/models/task.dart';

abstract class TaskServiceInterface {
  Future<Task> getTaskByUuid(String uuid);
  Stream<List<Task>> getTasks();
  Stream<List<Task>> getTodos();
  Stream<List<Task>> getDones();
  Future create(String text, DateTime dueDate, int estimatedMinutes);
  Future update(
      String uuid, String text, DateTime dueDate, int estimatedMinutes);
  Future delete(String uuid);
  Future toggleComplete(String uuid);
}
