import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/repositories/user_repository_interface.dart';
import 'package:flutter_todolist_app/models/user.dart';

final userRepository = Provider.autoDispose<UserRepositoryInterface>(
    (ref) => UserRepository(ref.read));

class UserRepository implements UserRepositoryInterface {
  final Reader read;
  final _usersReference = FirebaseFirestore.instance.collection('users');

  UserRepository(this.read);

  Future create(User user) async {
    return _usersReference.doc(user.id).set({
      'name': user.name,
      'createdAt': user.createdAt,
      'updatedAt': user.updatedAt,
    });
  }

  CollectionReference ref() {
    return _usersReference;
  }

  Future update(User user) async {
    return _usersReference.doc(user.id).update({
      'name': user.name,
      'updatedAt': user.updatedAt,
    });
  }

  Future delete(User user) async {
    return _usersReference.doc(user.id).delete();
  }
}
