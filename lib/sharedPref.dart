import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'task.dart';

class SharedPref {
  static final listItems = 'list_items';

  read() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getString(listItems);
    if (items == null) return <Task>[];
    List<Map<String, dynamic>> jsonArray =
        json.decode(items).cast<Map<String, dynamic>>();
    List<Task> tasks =
        jsonArray.map<Task>((task) => new Task.fromJson(task)).toList();
    return tasks;
  }

  save(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(listItems, json.encode(tasks));
  }

  delete() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(listItems);
  }
}
