import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/repositories/auth_repository.dart';
import 'package:flutter_todolist_app/services/auth_service_interface.dart';
import 'package:flutter_todolist_app/models/user.dart';

final authService =
    Provider.autoDispose<AuthServiceInterface>((ref) => AuthService(ref.read));

class AuthService implements AuthServiceInterface {
  final Reader read;

  AuthService(this.read);

  Future<User> signIn() async {
    try {
      return await read(authRepository).signIn();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await read(authRepository).signOut();
    } catch (e) {
      print(e);
    }
  }
}
