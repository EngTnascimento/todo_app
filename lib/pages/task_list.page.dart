import 'package:todo_app/database/handler.dart';
import 'package:todo_app/database/schemas/category.dart';
import 'package:todo_app/database/schemas/task.dart';
import 'package:todo_app/pages/widgets/app_bar.dart';
import 'package:todo_app/pages/widgets/search_task_form.dart';
import 'package:todo_app/pages/widgets/task_form.dart';
import 'package:todo_app/pages/widgets/task_list_item.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/services/task.service.dart';
import 'package:todo_app/services/notifications.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskListPage extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkTheme;

  const TaskListPage(
      {super.key, required this.toggleTheme, required this.isDarkTheme});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late final TaskService _taskService;
  final NotificationsService _notificationsService = NotificationsService();
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  late final int _currentUserId;
  List<Category> _categories = [];

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
  }

  void _deleteTask(Task task) async {
    await _taskService.deleteTask(task);
    _loadTasks();
  }

  Future<int> _addTask(Task task) async {
    int id = await _taskService.addTask(task);
    print('id from task list page: $id');
    _loadCategories(id);
    _loadTasks();
    return id;
  }

  void _completeTask(Task task) async {
    await _taskService.editTask(task);
    _loadTasks();
  }

  void _loadCategories(int taskId) async {
    DatabaseHandler db = DatabaseHandler();
    List<Category> categories = await db.getCategoriesByTask(taskId);
    setState(() {
      _categories = categories;
    });
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
      appBar: MyAppBar(
        title: 'Task List',
        actions: [
          Switch(
            value: widget.isDarkTheme,
            onChanged: (value) {
              widget.toggleTheme(value);
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
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
