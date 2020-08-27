import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_todolist_app/Repositories/TaskRepository.dart';
import 'package:flutter_todolist_app/Services/TaskService.dart';
import 'package:flutter_todolist_app/Models/Task.dart';
import 'package:flutter_todolist_app/TaskPage.dart';

class CompletedTaskPage extends StatefulWidget {
  CompletedTaskPage({Key key}) : super(key: key);

  @override
  _CompletedTaskPageState createState() => _CompletedTaskPageState();
}

class _CompletedTaskPageState extends State<CompletedTaskPage>
    with AutomaticKeepAliveClientMixin {
  Map<String, List<Task>> _mapTasks = {};
  TaskService _taskService = TaskService(new TaskRepository());

  void _loadTasks() async {
    Map<String, List<Task>> _map =
        await _taskService.getCompletedTasksGroupedByCompleteDate();
    setState(() {
      _mapTasks = _map;
    });
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return _mapTasks.length == 0
        ? Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.eco,
                    size: 48,
                    color: Colors.green,
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                  ),
                  Text('完了したタスクはありません'),
                ],
              ),
            ),
          )
        : Container(
            child: ListView(
              padding: EdgeInsets.only(
                top: 4.0,
                right: 4.0,
                bottom: 80.0,
                left: 4.0,
              ),
              children: _mapTasks.entries.map((e) {
                String key = e.key;
                List<Task> tasks = e.value;
                int etSum = tasks.fold(
                    0, (value, task) => value + (task.estimatedMinutes ?? 0));
                if (tasks.length == 0) return Container();
                return Container(
                  key: Key(key),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                            top: 16.0, right: 12.0, bottom: 16.0, left: 12.0),
                        child: Container(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                key == 'overdue'
                                    ? Icon(
                                        Icons.local_fire_department,
                                        color: Colors.pink,
                                      )
                                    : Container(),
                                Padding(
                                  padding: EdgeInsets.only(right: 4.0),
                                ),
                                Text(
                                  _dateFormatter(DateTime.parse(key)),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: key != 'overdue'
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color
                                        : Colors.pink,
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.timer,
                                      size: 18,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 4.0),
                                    ),
                                    Text(
                                        '${etSum.toString()}分 (${tasks.length}個)'),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 4.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: tasks.map((Task task) {
                          return Card(
                            key: Key(task.uuid),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            child: InkWell(
                              onTap: null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 0.0),
                                    child: IconButton(
                                      icon: Icon(
                                        task.completedAt == null
                                            ? Icons.check_box_outline_blank
                                            : Icons.check_box_outlined,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () => _handleCompleted(task),
                                      enableFeedback: false,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 10.0, right: 12.0, bottom: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            task.text,
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.0)),
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey[300],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.calendar_today,
                                                      color: Colors.green,
                                                      size: 16.0,
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 8.0)),
                                                    Text(
                                                      _dateFormatter(
                                                          DateTime.parse(
                                                              task.dueDate)),
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 8.0)),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey[300],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.timer,
                                                      size: 16.0,
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 8.0)),
                                                    Text(
                                                      (task.estimatedMinutes ??
                                                                  0) >
                                                              0
                                                          ? task.estimatedMinutes
                                                                  .round()
                                                                  .toString() +
                                                              '分'
                                                          : '時間なし',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
  }

  void _handleCompleted(Task task) async {
    await _taskService.toggleComplete(task.uuid);
    _loadTasks();
  }
}
