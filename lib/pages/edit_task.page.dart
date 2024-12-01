import 'package:todo_app/pages/widgets/app_bar.dart';
import 'package:todo_app/pages/widgets/edit_task_form.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/database/schemas/task.dart';
import 'package:todo_app/services/task.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;
  final Function onTaskEdited;

  const EditTaskPage(
      {super.key, required this.task, required this.onTaskEdited});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  String _taskTitle = '';
  String _taskDescription = '';
  DateTime _dueDate = DateTime.now();
  final _dueDateController = TextEditingController();
  late final TaskService _taskService;
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _taskService = TaskService(_currentUserId);
    _taskTitle = widget.task.title;
    _taskDescription = widget.task.description;
    _dueDate = widget.task.dueDate;
    _dueDateController.text = _dueDate.toString();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('currentUserId') ?? 0;
    });
  }

  void _editTask() async {
    widget.onTaskEdited();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Edit Task'),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: EditTaskForm(
            task: widget.task,
            onTaskSubmitted: _editTask,
          )),
    );
  }
}
