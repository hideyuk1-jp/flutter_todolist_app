import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_todolist_app/models/task.dart';

abstract class TaskRepositoryInterface {
  Future create(Task task);
  CollectionReference ref();
  Future update(Task task);
  Future delete(Task task);
}
