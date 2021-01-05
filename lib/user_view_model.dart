import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/services/auth_service.dart';
import 'package:flutter_todolist_app/services/auth_service_interface.dart';
import 'package:flutter_todolist_app/models/user.dart';

final userViewModelProvider =
    ChangeNotifierProvider((ref) => UserViewModel(ref.read(authService)));

class UserViewModel extends ChangeNotifier {
  UserViewModel(this._service);

  final AuthServiceInterface _service;

  User _user;

  User get user => _user;

  bool get isAuthenticated => _user != null;

  Future<void> signIn() {
    return _service.signIn().then((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signOut() {
    return _service.signOut().then((_) {
      _user = null;
      notifyListeners();
    });
  }
}
