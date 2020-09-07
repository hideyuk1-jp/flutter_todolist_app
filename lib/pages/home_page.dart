import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'package:flutter_todolist_app/repositories/task_repository.dart';
import 'package:flutter_todolist_app/services/task_service.dart';
import 'package:flutter_todolist_app/models/task.dart';
import 'package:flutter_todolist_app/common_parts.dart';
import 'package:flutter_todolist_app/pages/task_page.dart';
import 'package:flutter_todolist_app/pages/completed_task_page.dart';

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
