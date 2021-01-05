import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_todolist_app/pages/home_page.dart';
import 'package:flutter_todolist_app/pages/login_page.dart';
import 'package:flutter_todolist_app/user_view_model.dart';

class App extends HookWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final user =
        useProvider(userViewModelProvider.select((value) => value.user));

    return MaterialApp(
      title: 'Flutter TODO List',
      theme: ThemeData.light(),
      home: user != null ? HomePage() : LoginPage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en"),
        const Locale("ja"),
      ],
    );
  }
}
