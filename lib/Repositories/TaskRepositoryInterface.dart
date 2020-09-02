import 'package:flutter_todolist_app/Models/Task.dart';

abstract class TaskRepositoryInterface {
  Future create(Task task);
  Future<List<Task>> read();
  Future update(Task task);
  Future delete(Task task);
}
