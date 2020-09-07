import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_todolist_app/repositories/task_repository.dart';
import 'package:flutter_todolist_app/services/task_service.dart';
import 'package:flutter_todolist_app/models/task.dart';
import 'package:flutter_todolist_app/common_parts.dart';

class CompletedTaskPage extends StatefulWidget {
  final Stream<List<Task>> tasksStream;
  CompletedTaskPage({
    Key key,
    this.tasksStream,
  }) : super(key: key);

  @override
  _CompletedTaskPageState createState() => _CompletedTaskPageState();
}

class _CompletedTaskPageState extends State<CompletedTaskPage>
    with AutomaticKeepAliveClientMixin {
  TaskService _taskService = TaskService(new TaskRepository());

  Map<String, List<Task>> _formatTasks(List<Task> tasks) {
    Map<String, List<Task>> tasksGroupedByCompleteDate = {};
    for (Task task in tasks) {
      String key = DateFormat('yyyy-MM-dd').format(task.completedAt.toLocal());
      if (tasksGroupedByCompleteDate.containsKey(key))
        tasksGroupedByCompleteDate[key].add(task);
      else
        tasksGroupedByCompleteDate[key] = [task];
    }
    return tasksGroupedByCompleteDate;
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.tasksStream,
        builder: (_, AsyncSnapshot<List<Task>> snapshot) {
          List<Task> tasks = snapshot.data;
          return tasks == null || tasks.length == 0
              ? LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                    // 中身の高さによらず常にバウンスさせる
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      // 最小高さを親の高さと一緒にする
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: tasks == null
                            ? CircularProgressIndicator()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  GradientIcon(
                                    Icons.work_off,
                                    size: 48,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 16.0),
                                  ),
                                  Text('完了したタスクはありません'),
                                ],
                              ),
                      ),
                    ),
                  );
                })
              : ListView(
                  padding: EdgeInsets.only(
                    top: 4.0,
                    right: 4.0,
                    bottom: 80.0,
                    left: 4.0,
                  ),
                  children: _formatTasks(tasks).entries.map((e) {
                    String key = e.key;
                    List<Task> tasks = e.value;
                    int etSum = tasks.fold(0,
                        (value, task) => value + (task.estimatedMinutes ?? 0));
                    if (tasks.length == 0) return Container();
                    return Container(
                      key: Key(key),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: 16.0,
                                right: 12.0,
                                bottom: 16.0,
                                left: 12.0),
                            child: Container(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 4.0),
                                    ),
                                    Text(
                                      _dateFormatter(DateTime.parse(key)),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color,
                                      ),
                                    ),
                                    Spacer(),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          onPressed: () =>
                                              _handleCompleted(task),
                                          enableFeedback: false,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 10.0,
                                              right: 12.0,
                                              bottom: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                task.text,
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 8.0)),
                                              Row(
                                                children: <Widget>[
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
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
                                                                    right:
                                                                        8.0)),
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
                                                    padding:
                                                        EdgeInsets.symmetric(
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
                                                                    right:
                                                                        8.0)),
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
                );
        });
  }

  void _handleCompleted(Task task) async {
    _taskService.toggleComplete(task.uuid);
  }
}
