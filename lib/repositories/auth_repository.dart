import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter_todolist_app/services/user_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/repositories/auth_repository_interface.dart';
import 'package:flutter_todolist_app/models/user.dart';

final authRepository = Provider.autoDispose<AuthRepositoryInterface>(
    (ref) => AuthRepository(ref.read));

class AuthRepository implements AuthRepositoryInterface {
  final Reader read;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;

  AuthRepository(this.read);

  Future<User> signIn() async {
    GoogleSignInAccount googleCurrentUser = _googleSignIn.currentUser;
    if (googleCurrentUser == null)
      googleCurrentUser = await _googleSignIn.signInSilently();
    if (googleCurrentUser == null)
      googleCurrentUser = await _googleSignIn.signIn();
    if (googleCurrentUser == null) return null;

    GoogleSignInAuthentication googleAuth =
        await googleCurrentUser.authentication;
    final firebase.AuthCredential credential =
        firebase.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final firebase.User faUser =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + faUser.displayName);

    User user = await read(userService).getUserById(faUser.uid);

    if (user == null)
      user = await read(userService).create(faUser.uid, faUser.displayName);

    return user;
  }

  Future<void> signOut() {
    return _googleSignIn
        .signOut()
        .then((_) => _auth.signOut())
        .catchError((error) {
      debugPrint(error.toString());
      throw error;
    });
  }
}
