import 'package:desafio_login/database/schemas/task.dart';
import 'package:desafio_login/pages/widgets/search_task_form.dart';
import 'package:desafio_login/pages/widgets/task_form.dart';
import 'package:desafio_login/pages/widgets/task_list_item.dart';
import 'package:flutter/material.dart';
import 'package:desafio_login/services/task.service.dart';
import 'package:desafio_login/services/notifications.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late final TaskService _taskService;
  final NotificationsService _notificationsService = NotificationsService();
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  late final int _currentUserId;

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('currentUserId') ?? 0;
    });
    _taskService = TaskService(_currentUserId);
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId().then((_) {
      _loadTasks();
      _checkDueDates();
    });
  }

  Future<void> _loadTasks() async {
    await _taskService.loadTasks();
    setState(() {
      _tasks = _taskService.tasks;
      _filteredTasks = _taskService.tasks;
    });

    for (var task in _filteredTasks) {
      print('Loaded Task: ${task.toJson()}');
      if (task.isCompleted) {
        print('*** THIS TASK SHOULD NOT BE IN THE LIST ***');
      }
    }
  }

  void _deleteTask(Task task) async {
    await _taskService.deleteTask(task);
    _loadTasks();
  }

  void _addTask(Task task) async {
    await _taskService.addTask(task);
    _loadTasks();
  }

  void _completeTask(Task task) async {
    await _taskService.editTask(task);
    _loadTasks();
  }

  void _onSearch(List<Task> tasks, [bool reset = false]) {
    setState(() {
      if (reset) {
        _filteredTasks = _tasks;
        _loadTasks();
      } else {
        _filteredTasks = tasks;
      }
    });
  }

  Future<void> _checkDueDates() async {
    await _notificationsService.checkDueDates(_tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TaskForm(onTaskSubmitted: (task) => _addTask(task)),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTasks.length,
                itemBuilder: (context, index) {
                  return TaskListItem(
                    task: _filteredTasks[index],
                    onDeleteTask: _deleteTask,
                    onTaskEdited: _loadTasks,
                    onTaskCompleted: _completeTask,
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SearchTask(
                onSearch: _onSearch,
                tasks: _tasks,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
