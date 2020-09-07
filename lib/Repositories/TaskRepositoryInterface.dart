import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todolist_app/Models/Task.dart';

abstract class TaskRepositoryInterface {
  Future create(Task task);
  CollectionReference read();
  Future update(Task task);
  Future delete(Task task);
}
