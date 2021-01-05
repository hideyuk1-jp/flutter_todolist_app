import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/repositories/user_repository.dart';
import 'package:flutter_todolist_app/services/user_service_interface.dart';
import 'package:flutter_todolist_app/models/user.dart';

final userService =
    Provider.autoDispose<UserServiceInterface>((ref) => UserService(ref.read));

class UserService implements UserServiceInterface {
  final Reader read;

  UserService(this.read);

  Future<User> getUserById(String id) async {
    DocumentSnapshot doc = await read(userRepository).ref().doc(id).get();
    if (!doc.exists) return null;
    User user = User.fromSnapshot(doc);
    return user;
  }

  Future<User> create(String uid, String name) async {
    final now = DateTime.now();
    User user = new User.fromMap({
      'id': uid,
      'name': name,
      'created_at': now.toUtc(),
      'updated_at': now.toUtc()
    });
    await read(userRepository).create(user);
    return user;
  }

  Future update(String id, String name) async {
    final now = DateTime.now();
    User user = await getUserById(id);
    user.name = name;
    user.updatedAt = now.toUtc();
    await read(userRepository).update(user);
  }

  Future delete(String id) async {
    User user = await getUserById(id);
    await read(userRepository).delete(user);
  }
}
