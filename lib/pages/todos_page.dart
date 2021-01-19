import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flutter_todolist_app/services/task_service.dart';
import 'package:flutter_todolist_app/models/task.dart';
import 'package:flutter_todolist_app/common_parts.dart';

class TodosPage extends StatefulWidget {
  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TodosPageBody();
  }
}

class TodosPageBody extends HookWidget {
  Map<String, List<Task>> _formatTasks(List<Task> tasks) {
    final today =
        DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    Map<String, List<Task>> tasksGroupedByDueDate = {};
    for (Task task in tasks) {
      String key = DateTime.parse(task.dueDate).isBefore(today)
          ? 'overdue'
          : task.dueDate;
      if (tasksGroupedByDueDate.containsKey(key))
        tasksGroupedByDueDate[key].add(task);
      else
        tasksGroupedByDueDate[key] = [task];
    }
    return tasksGroupedByDueDate;
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: useProvider(taskService).getTodos(),
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
                    children: _formatTasks(tasks).entries.map((e) {
                      String key = e.key;
                      List<Task> tasks = e.value;
                      int etSum = tasks.fold(
                          0,
                          (value, task) =>
                              value + (task.estimatedMinutes ?? 0));
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                            ? _dateFormatter(
                                                DateTime.parse(key))
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.timer,
                                            size: 18,
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 4.0),
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
                                    onTap: () =>
                                        _openUpdateFormModal(context, task),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(top: 0.0),
                                          child: IconButton(
                                            icon: Icon(
                                              task.completedAt == null
                                                  ? Icons
                                                      .check_box_outline_blank
                                                  : Icons.check_box_outlined,
                                              color: Colors.grey[600],
                                            ),
                                            onPressed: () =>
                                                _handleCompleted(context, task),
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
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 8.0,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              Colors.grey[300],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color: Colors.green,
                                                            size: 16.0,
                                                          ),
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          8.0)),
                                                          Text(
                                                            _dateFormatter(
                                                                DateTime.parse(
                                                                    task.dueDate)),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 8.0)),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 8.0,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color:
                                                              Colors.grey[300],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.timer,
                                                            size: 16.0,
                                                          ),
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .only(
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
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateFormModal(context),
        tooltip: 'タスクを追加',
        child: GradientCircleIconButton(icon: Icon(Icons.add)),
      ),
    );
  }

  void _openCreateFormModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return TaskCreateFormWidget();
      },
    );
  }

  void _openUpdateFormModal(BuildContext context, Task task) {
    context.read(updateFormProvider).loadTask(task);
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
          );
        });
      },
    );
  }

  void _handleCompleted(BuildContext context, Task task) async {
    context.read(taskService).toggleComplete(task.uuid);
  }
}

final createFormProvider = ChangeNotifierProvider((ref) => FormNotifier());

class FormNotifier with ChangeNotifier {
  TextEditingController _textController;
  bool _isComposing;
  DateTime _dueDate;
  double _estimatedMinutes;

  FormNotifier() {
    _textController = TextEditingController();
    _isComposing = false;
    _dueDate = new DateTime.now();
    _estimatedMinutes = 0.0;
  }

  TextEditingController get textController => _textController;
  bool get isComposing => _isComposing;
  DateTime get dueDate => _dueDate;
  double get estimatedMinutes => _estimatedMinutes;

  set textController(TextEditingController controller) {
    _textController = controller;
    notifyListeners();
  }

  set isComposing(bool flag) {
    _isComposing = flag;
    notifyListeners();
  }

  set dueDate(DateTime date) {
    _dueDate = date;
    notifyListeners();
  }

  set estimatedMinutes(double minutes) {
    _estimatedMinutes = minutes;
    notifyListeners();
  }

  void loadTask(Task task) {
    _textController = TextEditingController(text: task.text);
    _isComposing = task.text.length > 0;
    _dueDate = DateTime.parse(task.dueDate);
    _estimatedMinutes = task.estimatedMinutes.toDouble();
    notifyListeners();
  }
}

class TaskCreateFormWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final createForm = useProvider(createFormProvider);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: <Widget>[
              TextField(
                controller: createForm.textController,
                onChanged: (String text) {
                  createForm.isComposing = text.length > 0;
                },
                onSubmitted: createForm.isComposing
                    ? (String text) => _handleSubmitted(
                        text,
                        createForm.dueDate,
                        createForm.estimatedMinutes.round(),
                        context)
                    : null,
                autofocus: true,
                decoration: InputDecoration.collapsed(hintText: 'タスクの内容を入力'),
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
                        _dateFormatter(createForm.dueDate),
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
                        createForm.estimatedMinutes > 0
                            ? createForm.estimatedMinutes.round().toString() +
                                '分'
                            : '時間なし',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _openTimeSliderDialog(context),
                      color: Colors.green,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: IconButton(
                      icon: createForm.isComposing
                          ? GradientIcon(Icons.send)
                          : Icon(Icons.send),
                      color: Theme.of(context).accentColor,
                      onPressed: createForm.isComposing
                          ? () => _handleSubmitted(
                              createForm.textController.text,
                              createForm.dueDate,
                              createForm.estimatedMinutes.round(),
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
  }

  void _handleSubmitted(String text, DateTime dueDate, int estimatedMiutes,
      BuildContext context) async {
    final createForm = context.read(createFormProvider);
    context.read(taskService).create(text, dueDate, estimatedMiutes);
    createForm.textController.clear();
    createForm.isComposing = false;
    createForm.dueDate = new DateTime.now();
    createForm.estimatedMinutes = 0.0;
    Navigator.pop(context);
  }

  Future<Null> _selectDueDate(BuildContext context) async {
    final createForm = context.read(createFormProvider);
    final DateTime picked = await showDatePicker(
        helpText: '期限を選択',
        context: context,
        locale: const Locale("ja"),
        initialDate: createForm.dueDate,
        firstDate: new DateTime(2016),
        lastDate: new DateTime.now().add(new Duration(days: 360)));
    if (picked != null) createForm.dueDate = picked;
  }

  void _openTimeSliderDialog(BuildContext context) async {
    double _time = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimePickerDialog(
            initialTime: context.read(createFormProvider).estimatedMinutes);
      },
    );
    if (_time != null)
      context.read(createFormProvider).estimatedMinutes = _time;
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

class TimePickerDialog extends StatefulWidget {
  final double initialTime;

  const TimePickerDialog({Key key, this.initialTime}) : super(key: key);
  @override
  _TimePickerDialogState createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
  double _time;

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'タスクの完了にかかる時間',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Slider(
          value: _time,
          label: _time > 0 ? _time.round().toString() + '分' : '時間なし',
          min: 0,
          max: 360,
          divisions: 24,
          onChanged: (double value) {
            setState(() {
              _time = value;
            });
          },
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("キャンセル"),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.pop(context, _time);
          },
        ),
      ],
    );
  }
}

final updateFormProvider = ChangeNotifierProvider((ref) => FormNotifier());

class TaskUpdateFormWidget extends HookWidget {
  final Task task;

  TaskUpdateFormWidget({this.task});

  @override
  Widget build(BuildContext context) {
    final updateForm = useProvider(updateFormProvider);
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
                      onPressed: () => _openDeleteAlertDialog(context),
                    ),
                  ],
                ),
              ),
              Divider(),
              TextField(
                controller: updateForm.textController,
                onChanged: (String text) {
                  updateForm.isComposing = text.length > 0;
                },
                onSubmitted: updateForm.isComposing
                    ? (String text) => _handleSubmitted(
                          task.uuid,
                          text,
                          updateForm.dueDate,
                          updateForm.estimatedMinutes.round(),
                          context,
                        )
                    : null,
                autofocus: true,
                decoration: InputDecoration.collapsed(hintText: 'タスクの内容を入力'),
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
                        _dateFormatter(updateForm.dueDate),
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
                        updateForm.estimatedMinutes > 0
                            ? updateForm.estimatedMinutes.round().toString() +
                                '分'
                            : '時間なし',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _openTimeSliderDialog(context),
                      color: Colors.green,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: IconButton(
                      icon: updateForm.isComposing
                          ? GradientIcon(Icons.send)
                          : Icon(Icons.send),
                      color: Colors.blue,
                      onPressed: updateForm.isComposing
                          ? () => _handleSubmitted(
                                task.uuid,
                                updateForm.textController.text,
                                updateForm.dueDate,
                                updateForm.estimatedMinutes.round(),
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
    final updateForm = context.read(updateFormProvider);
    final DateTime picked = await showDatePicker(
        context: context,
        locale: const Locale("ja"),
        initialDate: updateForm.dueDate,
        firstDate: new DateTime(2016),
        lastDate: new DateTime.now().add(new Duration(days: 360)));
    if (picked != null) updateForm.dueDate = picked;
  }

  void _openTimeSliderDialog(BuildContext context) async {
    double _time = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return TimePickerDialog(
            initialTime: context.read(updateFormProvider).estimatedMinutes);
      },
    );
    if (_time != null)
      context.read(updateFormProvider).estimatedMinutes = _time;
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
    context.read(taskService).update(uuid, text, dueDate, estimatedMiutes);
    Navigator.pop(context);
  }

  void _openDeleteAlertDialog(BuildContext context) async {
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
              onPressed: () => _handleDeleted(task.uuid, context),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleted(String uuid, BuildContext context) async {
    context.read(taskService).delete(uuid);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
