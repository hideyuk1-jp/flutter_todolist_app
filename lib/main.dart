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
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  SharedPref sharedPref = SharedPref();

  void _init() async {
    _tasks = await sharedPref.read();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _init();
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
                            icon: Icon(_tasks[index].completedAt == null
                                ? Icons.check_box_outline_blank
                                : Icons.check_box),
                            onPressed: () => _handleCompleted(
                                index, _tasks[index].completedAt != null),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Text(_name, style: Theme.of(context).textTheme.headline4),
                              Container(
                                margin: EdgeInsets.all(12.0),
                                child: Text(_tasks[index].text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: _tasks.length,
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

  void _handleSubmitted(String text, BuildContext context) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    Task task = Task.fromMap({'text': text, 'completed_at': null});
    setState(() {
      _tasks.add(task);
    });
    sharedPref.save(_tasks);
    _focusNode.requestFocus();
    Navigator.pop(context);
  }

  void _handleCompleted(int index, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        _tasks[index].completedAt = null;
      } else {
        final now = DateTime.now();
        _tasks[index].completedAt = now.toUtc().toIso8601String();
      }
    });
    sharedPref.save(_tasks);
  }
}
