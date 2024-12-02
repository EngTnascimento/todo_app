import 'package:todo_app/database/handler.dart';
import 'package:todo_app/database/schemas/category.dart';
import 'package:todo_app/database/schemas/task.dart';
import 'package:todo_app/services/task.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskForm extends StatefulWidget {
  final Function onTaskSubmitted;

  const TaskForm({super.key, required this.onTaskSubmitted});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TaskService _taskService;
  late int _currentUserId;
  String _taskTitle = '';
  String _taskDescription = '';
  DateTime _dueDate = DateTime.now();
  List<Category> _categories = [];
  List<Category> _selectedCategories = [];
  List<Map<String, String>>? _dataSource;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCurrentUserId();
    await _loadCategories();
    _dataSource = _setDataSource();
    setState(() {});
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('currentUserId')!;
    });
    _taskService = TaskService(_currentUserId);
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categories = [
        Category(id: 1, name: 'Red', userId: _currentUserId),
        Category(id: 2, name: 'Blue', userId: _currentUserId),
        Category(id: 3, name: 'Green', userId: _currentUserId),
      ];
    });
  }

  List<Map<String, String>> _setDataSource() {
    List<Map<String, String>> dataSource = [];
    List<Category> categories = _categories;
    for (var category in categories) {
      dataSource.add({
        "display": category.name,
        "value": category.id.toString(),
      });
    }
    for (var m in dataSource) {
      if (m['display'] == null || m['value'] == null) {
        print('*** error here ***');
      }
    }
    return dataSource;
  }

  Future<void> _attachCategories(int taskId) async {
    print('calling attachCateoriesToTask');
    DatabaseHandler db = DatabaseHandler();
    await db.attachCateoriesToTask(_selectedCategories, taskId);
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
      int id = await widget.onTaskSubmitted(task);
      print('Id from submit: $id');
      await _attachCategories(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Task Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a task title';
              }
              return null;
            },
            onSaved: (value) => _taskTitle = value!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Task Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a task description';
              }
              return null;
            },
            onSaved: (value) => _taskDescription = value!,
          ),
          MultiSelectFormField(
            title: const Text('Categories'),
            validator: (value) {
              if (value == null || value.length == 0) {
                return 'Please select one or more categories';
              }
              return null;
            },
            dataSource: const [
              {"display": "Red", "value": "1"},
              {"display": "Blue", "value": "2"},
              {"display": "Green", "value": "3"},
            ],
            textField: 'display',
            valueField: 'value',
            okButtonLabel: 'Save',
            cancelButtonLabel: 'Cancel',
            onSaved: (values) {
              print('TaskForm values: $values');
              print('categories count: ${_categories.length}');
              setState(() {
                _selectedCategories = _categories
                    .where(
                        (category) => values.contains(category.id.toString()))
                    .toList();
              });
            },
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 108, 136, 158),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 5)),
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
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
