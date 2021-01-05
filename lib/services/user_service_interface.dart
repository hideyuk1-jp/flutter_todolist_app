import 'package:flutter_todolist_app/models/user.dart';

abstract class UserServiceInterface {
  Future<User> getUserById(String id);
  Future<User> create(String uid, String name);
  Future update(String id, String name);
  Future delete(String id);
}
