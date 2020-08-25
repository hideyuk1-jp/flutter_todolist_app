import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_todolist_app/Repositories/TaskRepository.dart';
import 'package:flutter_todolist_app/Services/TaskService.dart';
import 'package:flutter_todolist_app/Models/Task.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TODO List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskPage(),
    );
  }
}

class TaskPage extends StatefulWidget {
  TaskPage({Key key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with TickerProviderStateMixin {
  List<Task> _incompletedTasks = <Task>[];

  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  DateTime _dueDate = new DateTime.now();
  // int _estimatedMinutes = 5;

  TaskService _taskService = TaskService(new TaskRepository());

  void _loadTasks() async {
    List<Task> _tasks = await _taskService.getIncompletedTasks();
    print(json.encode(_tasks));
    setState(() {
      _incompletedTasks = _tasks;
    });
  }

  Future<Null> _selectDueDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dueDate,
        firstDate: new DateTime(2016),
        lastDate: new DateTime.now().add(new Duration(days: 360)));
    if (picked != null) setState(() => _dueDate = picked);
  }

  String _dateFormatter(DateTime date) {
    DateTime today = new DateTime.now();
    Map<int, String> conv = {-1: '昨日', 0: '今日', 1: '明日', 2: '明後日'};
    for (int key in conv.keys) {
      DateTime cdate = today.add(new Duration(days: key));
      if (date.year == cdate.year &&
          date.month == cdate.month &&
          date.day == cdate.day) return conv[key];
    }
    if (today.year == date.year) return DateFormat('M月d日').format(date);
    return DateFormat('yyyy年M月d日').format(date);
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Icon(Icons.style),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                  top: 16.0, right: 12.0, bottom: 16.0, left: 12.0),
              child: Container(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '今日 : 8月24日(月)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _incompletedTasks.map((Task task) {
                  return Card(
                    key: Key(task.uuid),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 1.0),
                          child: IconButton(
                            icon: Icon(task.completedAt == null
                                ? Icons.radio_button_unchecked
                                : Icons.check_box),
                            onPressed: () => _handleCompleted(task),
                            enableFeedback: false,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 12.0, right: 12.0, bottom: 12.0),
                            child: Text(
                              task.text,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 1.0),
                          child: IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () => print('Press!'),
                            enableFeedback: false,
                          ),
                        ),
                        // タップでEタスクのdit画面へ
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (BuildContext context, setState) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _textController,
                            onChanged: (String text) {
                              setState(() {
                                _isComposing = text.length > 0;
                              });
                            },
                            onSubmitted: _isComposing
                                ? (String text) =>
                                    _handleSubmitted(text, _dueDate, context)
                                : null,
                            autofocus: true,
                            decoration:
                                InputDecoration.collapsed(hintText: 'タスクを追加'),
                            focusNode: _focusNode,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                child: OutlineButton.icon(
                                  icon: Icon(
                                    Icons.calendar_today,
                                    color: Colors.green,
                                    size: 16.0,
                                  ),
                                  label: Text(
                                    _dateFormatter(_dueDate),
                                    //DateFormat('yyyy年M月d日').format(_dueDate),
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  onPressed: () => _selectDueDate(context),
                                  color: Colors.green,
                                  shape: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                ),
                              ),
                              /*Padding(padding: EdgeInsets.only(right: 8.0)),
                              Container(
                                child: OutlineButton.icon(
                                  icon: Icon(
                                    Icons.timer,
                                    size: 16.0,
                                  ),
                                  label: Text(
                                    "時間なし",
                                    style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  onPressed: () {},
                                  color: Colors.green,
                                  shape: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                ),
                              ),*/
                              Spacer(),
                              Container(
                                child: IconButton(
                                  icon: const Icon(Icons.send),
                                  color: Colors.blue,
                                  onPressed: _isComposing
                                      ? () => _handleSubmitted(
                                          _textController.text,
                                          _dueDate,
                                          context)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
          );
        },
        tooltip: 'タスクを追加',
        child: Icon(Icons.add),
      ),
    );
  }

  void _handleSubmitted(
      String text, DateTime dueDate, BuildContext context) async {
    await _taskService.create(text, dueDate);
    _textController.clear();
    setState(() {
      _isComposing = false;
      _dueDate = new DateTime.now();
    });
    _focusNode.requestFocus();
    _loadTasks();
    Navigator.pop(context);
  }

  void _handleCompleted(Task task) async {
    await _taskService.toggleComplete(task.uuid);
    _loadTasks();
  }
}
