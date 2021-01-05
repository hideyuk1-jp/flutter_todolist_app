import 'package:flutter_todolist_app/models/user.dart';

abstract class AuthServiceInterface {
  Future<User> signIn();
  Future<void> signOut();
}
