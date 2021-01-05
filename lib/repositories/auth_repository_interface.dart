import 'package:flutter_todolist_app/models/user.dart';

abstract class AuthRepositoryInterface {
  Future<User> signIn();
  Future<void> signOut();
}
