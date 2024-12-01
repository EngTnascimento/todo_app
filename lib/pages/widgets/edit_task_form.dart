import 'package:flutter/material.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:todo_app/database/handler.dart';
import 'package:todo_app/database/schemas/category.dart';
import 'package:todo_app/database/schemas/task.dart';
import 'package:todo_app/services/task.service.dart';
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
  final List<Category> _categories = [];
  List<Category> _selectedCategories = [];
  late TaskService _taskService;

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('currentUserId')!;
    });
    _taskService = TaskService(_currentUserId);
  }

  Future<void> _updateCategories(Task task) async {
    DatabaseHandler db = DatabaseHandler();
    await db.updateCategoriesToTask(_selectedCategories, task);
  }

  void _submit() async {
    Task task = Task(
        id: widget.task.id,
        userId: _currentUserId,
        title: _taskTitle,
        description: _taskDescription,
        dueDate: _dueDate,
        isCompleted: widget.task.isCompleted);
    await _taskService.editTask(task);
    _updateCategories(task);
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
              setState(() {
                _taskDescription = value!;
              }),
            },
          ),
          MultiSelectFormField(
            autovalidate: AutovalidateMode.disabled,
            title: Text('Categories'),
            validator: (value) {
              if (value == null || value.length == 0) {
                return 'Please select one or more categories';
              }
              return null;
            },
            dataSource: _categories.map((category) {
              return {
                "display": category.name,
                "value": category.id,
              };
            }).toList(),
            textField: 'display',
            valueField: 'value',
            okButtonLabel: 'OK',
            cancelButtonLabel: 'Cancel',
            onSaved: (values) {
              setState(() {
                _selectedCategories = values;
              });
            },
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 108, 136, 158),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(DateFormat('yyyy-MM-dd').format(_dueDate)),
                  SizedBox(width: 8),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              }
              _submit();
            },
            child: Text('Edit Task'),
          ),
        ],
      ),
    );
  }
}
