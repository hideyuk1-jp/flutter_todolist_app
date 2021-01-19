import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/user_view_model.dart';

class LoginPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('ログインしてください'),
              RaisedButton(
                child: Text('Googleで続行'),
                onPressed: () async {
                  await context.read(userViewModelProvider).signIn();
                },
              ),
            ]),
      ),
    );
  }
}
