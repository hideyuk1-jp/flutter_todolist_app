import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_todolist_app/Repositories/TaskRepository.dart';
import 'package:flutter_todolist_app/Services/TaskService.dart';
import 'package:flutter_todolist_app/Models/Task.dart';
import 'package:flutter_todolist_app/CommonParts.dart';

class TaskPage extends StatefulWidget {
  final Map<String, List<Task>> tasksMap;
  final loadTasks;
  TaskPage({
    Key key,
    this.tasksMap,
    this.loadTasks,
  }) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with AutomaticKeepAliveClientMixin {
  final FocusNode _focusNode = FocusNode();
  TaskService _taskService = TaskService(new TaskRepository());

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
  void initState() {
    super.initState();
    widget.loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: widget.loadTasks,
        child: widget.tasksMap.length == 0
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          GradientIcon(
                            Icons.wb_sunny,
                            size: 48,
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                          ),
                          Text('未完了のタスクはありません'),
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
                children: widget.tasksMap.entries.map((e) {
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
                                    key != 'overdue'
                                        ? _dateFormatter(DateTime.parse(key))
                                        : '期限切れ',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                onTap: () => _openUpdateFormModal(task),
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
                                            top: 10.0,
                                            right: 12.0,
                                            bottom: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              task.text,
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 8.0)),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateFormModal(),
        tooltip: 'タスクを追加',
        child: GradientCircleIconButton(icon: Icon(Icons.add)),
      ),
    );
  }

  void _openCreateFormModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return TaskCreateFormWidget(
            loadTasks: widget.loadTasks,
            focusNode: _focusNode,
            taskService: _taskService,
          );
        });
      },
    );
  }

  void _openUpdateFormModal(Task task) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return TaskUpdateFormWidget(
            task: task,
            loadTasks: widget.loadTasks,
            focusNode: _focusNode,
            taskService: _taskService,
          );
        });
      },
    );
  }

  void _handleCompleted(Task task) async {
    await _taskService.toggleComplete(task.uuid);
    widget.loadTasks();
  }
}

class TaskCreateFormWidget extends StatefulWidget {
  final loadTasks;
  final FocusNode focusNode;
  final TaskService taskService;

  TaskCreateFormWidget({this.loadTasks, this.focusNode, this.taskService});

  @override
  _TaskCreateFormWidgetState createState() => _TaskCreateFormWidgetState();
}

class _TaskCreateFormWidgetState extends State<TaskCreateFormWidget> {
  TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  DateTime _dueDate = new DateTime.now();
  double _estimatedMinutes = 0.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    ? (String text) => _handleSubmitted(
                        text, _dueDate, _estimatedMinutes.round(), context)
                    : null,
                autofocus: true,
                decoration: InputDecoration.collapsed(hintText: 'タスクの内容を入力'),
                focusNode: widget.focusNode,
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
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _selectDueDate(context),
                      color: Colors.green,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 8.0)),
                  Container(
                    child: OutlineButton.icon(
                      icon: Icon(
                        Icons.timer,
                        size: 16.0,
                      ),
                      label: Text(
                        _estimatedMinutes > 0
                            ? _estimatedMinutes.round().toString() + '分'
                            : '時間なし',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _openTimeSliderDialog(context, setState),
                      color: Colors.green,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: IconButton(
                      icon: _isComposing
                          ? GradientIcon(Icons.send)
                          : Icon(Icons.send),
                      color: Theme.of(context).accentColor,
                      onPressed: _isComposing
                          ? () => _handleSubmitted(_textController.text,
                              _dueDate, _estimatedMinutes.round(), context)
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
  }

  void _handleSubmitted(String text, DateTime dueDate, int estimatedMiutes,
      BuildContext context) async {
    await widget.taskService.create(text, dueDate, estimatedMiutes);
    _textController.clear();
    setState(() {
      _isComposing = false;
      _dueDate = new DateTime.now();
      _estimatedMinutes = 0.0;
    });
    widget.focusNode.requestFocus();
    widget.loadTasks();
    Navigator.pop(context);
  }

  Future<Null> _selectDueDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        helpText: '期限を選択',
        context: context,
        locale: const Locale("ja"),
        initialDate: _dueDate,
        firstDate: new DateTime(2016),
        lastDate: new DateTime.now().add(new Duration(days: 360)));
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _openTimeSliderDialog(BuildContext context, setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return SimpleDialog(
            title: Text(
              'タスクの完了にかかる時間',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            children: <Widget>[
              Slider(
                value: _estimatedMinutes,
                label: _estimatedMinutes > 0
                    ? _estimatedMinutes.round().toString() + '分'
                    : '時間なし',
                min: 0,
                max: 360,
                divisions: 24,
                onChanged: (double value) {
                  setState(() {
                    _estimatedMinutes = value;
                  });
                },
              )
            ],
          );
        });
      },
    );
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
}

class TaskUpdateFormWidget extends StatefulWidget {
  final Task task;
  final loadTasks;
  final FocusNode focusNode;
  final TaskService taskService;

  TaskUpdateFormWidget(
      {this.task, this.loadTasks, this.focusNode, this.taskService});

  @override
  _TaskUpdateFormWidgetState createState() =>
      _TaskUpdateFormWidgetState(task: task);
}

class _TaskUpdateFormWidgetState extends State<TaskUpdateFormWidget> {
  Task task;
  TextEditingController _textController;
  bool _isComposing;
  DateTime _dueDate;
  double _estimatedMinutes;

  _TaskUpdateFormWidgetState({this.task}) {
    _loadSingleTask();
    _textController = TextEditingController(text: task.text);
    _isComposing = task.text.length > 0;
    _dueDate = DateTime.parse(task.dueDate);
    _estimatedMinutes = task.estimatedMinutes.toDouble();
  }

  void _loadSingleTask() async {
    task = await widget.taskService.getTaskByUuid(task.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding:
            EdgeInsets.only(top: 8.0, right: 16.0, bottom: 16.0, left: 16.0),
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: <Widget>[
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'タスクを編集',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    OutlineButton(
                      child: Text(
                        '削除',
                        style: TextStyle(
                          color: Colors.pink,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      onPressed: () => _openDeleteAlertDialog(),
                    ),
                  ],
                ),
              ),
              Divider(),
              TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _isComposing
                    ? (String text) => _handleSubmitted(
                          task.uuid,
                          text,
                          _dueDate,
                          _estimatedMinutes.round(),
                          context,
                        )
                    : null,
                autofocus: true,
                decoration: InputDecoration.collapsed(hintText: 'タスクの内容を入力'),
                focusNode: widget.focusNode,
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
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _selectDueDate(context),
                      color: Colors.green,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 8.0)),
                  Container(
                    child: OutlineButton.icon(
                      icon: Icon(
                        Icons.timer,
                        size: 16.0,
                      ),
                      label: Text(
                        _estimatedMinutes > 0
                            ? _estimatedMinutes.round().toString() + '分'
                            : '時間なし',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _openTimeSliderDialog(context, setState),
                      color: Colors.green,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: IconButton(
                      icon: _isComposing
                          ? GradientIcon(Icons.send)
                          : Icon(Icons.send),
                      color: Colors.blue,
                      onPressed: _isComposing
                          ? () => _handleSubmitted(
                                task.uuid,
                                _textController.text,
                                _dueDate,
                                _estimatedMinutes.round(),
                                context,
                              )
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
  }

  Future<Null> _selectDueDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        locale: const Locale("ja"),
        initialDate: _dueDate,
        firstDate: new DateTime(2016),
        lastDate: new DateTime.now().add(new Duration(days: 360)));
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _openTimeSliderDialog(BuildContext context, setState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return SimpleDialog(
            title: Text(
              'タスクの完了にかかる時間',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            children: <Widget>[
              Slider(
                value: _estimatedMinutes,
                label: _estimatedMinutes > 0
                    ? _estimatedMinutes.round().toString() + '分'
                    : '時間なし',
                min: 0,
                max: 360,
                divisions: 24,
                onChanged: (double value) {
                  setState(() {
                    _estimatedMinutes = value;
                  });
                },
              )
            ],
          );
        });
      },
    );
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

  void _handleSubmitted(String uuid, String text, DateTime dueDate,
      int estimatedMiutes, BuildContext context) async {
    await widget.taskService.update(uuid, text, dueDate, estimatedMiutes);
    widget.focusNode.requestFocus();
    widget.loadTasks();
    Navigator.pop(context);
  }

  void _openDeleteAlertDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('"${task.text}"を削除しますか？'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('いいえ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('はい'),
              onPressed: () => _handleDeleted(task.uuid),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleted(String uuid) async {
    await widget.taskService.delete(uuid);
    widget.focusNode.requestFocus();
    widget.loadTasks();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
