import 'package:desafio_login/database/schemas/task.dart';
import 'package:desafio_login/services/task.service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskForm extends StatefulWidget {
  final Function onTaskSubmitted;

  TaskForm({required this.onTaskSubmitted});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  String _taskTitle = '';
  String _taskDescription = '';
  DateTime _dueDate = DateTime.now();
  late int _currentUserId;
  late TaskService _taskService;

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('currentUserId')!;
    });
    _taskService = TaskService(_currentUserId);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Task task = Task(
        userId: _currentUserId,
        title: _taskTitle,
        description: _taskDescription,
        dueDate: _dueDate,
        isCompleted: false,
      );
      widget.onTaskSubmitted(task);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'Task Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a task title';
              }
              return null;
            },
            onSaved: (value) => _taskTitle = value!,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Task Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a task description';
              }
              return null;
            },
            onSaved: (value) => _taskDescription = value!,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Due Date'),
            validator: (value) {
              if (value == null) {
                return 'Please select a due date';
              }
              return null;
            },
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _dueDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() {
                  _dueDate = picked;
                });
              }
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _submit();
            },
            child: Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
