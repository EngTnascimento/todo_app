import 'package:flutter/material.dart';
import 'package:desafio_login/database/schemas/task.dart';
import 'package:desafio_login/services/task.service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditTaskForm extends StatefulWidget {
  final Task task;
  final Function onTaskSubmitted;

  EditTaskForm({required this.task, required this.onTaskSubmitted});

  @override
  _EditTaskFormState createState() => _EditTaskFormState();
}

class _EditTaskFormState extends State<EditTaskForm> {
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
    print('submitting task: $_taskTitle, $_taskDescription, $_dueDate');
    await _taskService.editTask(Task(
        id: widget.task.id,
        userId: _currentUserId,
        title: _taskTitle,
        description: _taskDescription,
        dueDate: _dueDate,
        isCompleted: widget.task.isCompleted));
    widget.onTaskSubmitted();
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _taskTitle = widget.task.title;
    _taskDescription = widget.task.description;
    _dueDate = widget.task.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: _taskTitle,
            decoration: InputDecoration(labelText: 'Task Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a task title';
              }
              return null;
            },
            onSaved: (value) => {
              print('new _taskTitle: $value'),
              setState(() {
                _taskTitle = value!;
              })
            },
          ),
          TextFormField(
            initialValue: _taskDescription,
            decoration: InputDecoration(labelText: 'Task Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a task description';
              }
              return null;
            },
            onSaved: (value) => {
              print("new _taskDescription: $value"),
              setState(() {
                _taskDescription = value!;
              }),
            },
          ),
          TextFormField(
            initialValue: DateFormat('yyyy-MM-dd').format(_dueDate),
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
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              }
              print(
                  '####################### form saved #######################');
              _submit();
            },
            child: Text('Edit Task'),
          ),
        ],
      ),
    );
  }
}
