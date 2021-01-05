import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_todolist_app/models/user.dart';

abstract class UserRepositoryInterface {
  Future create(User user);
  CollectionReference ref();
  Future update(User user);
  Future delete(User user);
}
