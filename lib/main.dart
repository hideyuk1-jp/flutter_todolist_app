import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'package:flutter_todolist_app/Repositories/TaskRepository.dart';
import 'package:flutter_todolist_app/Services/TaskService.dart';
import 'package:flutter_todolist_app/TaskPage.dart';
import 'package:flutter_todolist_app/CompletedTaskPage.dart';
import 'package:flutter_todolist_app/Models/Task.dart';
import 'package:flutter_todolist_app/CommonParts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TODO List',
      theme: ThemeData.light(),
      home: HomePage(),
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<List<Task>> _todoTasks;
  Stream<List<Task>> _doneTasks;
  TaskService _taskService = TaskService(new TaskRepository());
  int _selectedIndex = 0;
  PageController _pageController;

  _HomePageState() {
    this._todoTasks = _taskService.getIncompletedTasks();
    this._doneTasks = _taskService.getCompletedTasks();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _selectedIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pageWidgets = [
      TaskPage(tasksStream: _todoTasks),
      CompletedTaskPage(tasksStream: _doneTasks),
    ];

    return Scaffold(
      appBar: GradientAppBar(
        title: Center(
          child: Icon(Icons.style),
        ),
        backgroundColorStart: Colors.cyan,
        backgroundColorEnd: Colors.indigo,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pageWidgets,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            activeIcon: GradientIcon(Icons.inbox),
            title: Text('ToDo'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            activeIcon: GradientIcon(Icons.check),
            title: Text('Done'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onPageChanged(int index) => setState(() => _selectedIndex = index);

  void _onItemTapped(int index) {
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 160), curve: Curves.easeIn);
  }
}
