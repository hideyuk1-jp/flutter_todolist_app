import 'package:flutter/material.dart';
import 'package:flutter_todolist_app/sharedPref.dart';
import 'task.dart';

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
      home: TaskPage(title: 'Flutter TODO'),
    );
  }
}

class TaskPage extends StatefulWidget {
  TaskPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with TickerProviderStateMixin {
  List<Task> _tasks = <Task>[];
  List<Task> _completedTasks = <Task>[];
  List<Task> _incompletedTasks = <Task>[];
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  SharedPref sharedPref = SharedPref();

  void _loadTasks() async {
    List<Task> tasks = await sharedPref.readTasks();
    setState(() {
      _tasks = tasks;
      _completedTasks =
          tasks.where((item) => item.completedAt != null).toList();
      _incompletedTasks =
          tasks.where((item) => item.completedAt == null).toList();
    });
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
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemBuilder: (_, int index) {
                  return Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                                _incompletedTasks[index].completedAt == null
                                    ? Icons.check_box_outline_blank
                                    : Icons.check_box),
                            onPressed: () =>
                                _handleCompleted(_incompletedTasks[index]),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text(_name, style: Theme.of(context).textTheme.headline4),
                              Container(
                                margin: EdgeInsets.all(12.0),
                                child: Text(_incompletedTasks[index].text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: _incompletedTasks.length,
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (BuildContext context, setState) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: TextField(
                              controller: _textController,
                              onChanged: (String text) {
                                setState(() {
                                  _isComposing = text.length > 0;
                                });
                              },
                              onSubmitted: _isComposing
                                  ? (String text) =>
                                      _handleSubmitted(text, context)
                                  : null,
                              autofocus: true,
                              decoration:
                                  InputDecoration.collapsed(hintText: 'タスクを追加'),
                              focusNode: _focusNode,
                            ),
                          ),
                          Container(
                            child: IconButton(
                              icon: const Icon(Icons.send),
                              color: Colors.blue,
                              onPressed: _isComposing
                                  ? () => _handleSubmitted(
                                      _textController.text, context)
                                  : null,
                            ),
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

  void _handleSubmitted(String text, BuildContext context) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    Task task = Task.fromMap({'text': text});
    await sharedPref.createTask(task);
    _focusNode.requestFocus();
    _loadTasks();
    Navigator.pop(context);
  }

  void _handleCompleted(Task task) async {
    if (task.completedAt != null) {
      task.completedAt = null;
    } else {
      final now = DateTime.now();
      task.completedAt = now.toUtc();
    }
    await sharedPref.editTask(task);
    _loadTasks();
  }
}
