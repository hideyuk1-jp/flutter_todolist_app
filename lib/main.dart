import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/app.dart';

void main() {
  runApp(
    ProviderScope(
      child: App(),
    ),
  );
}
