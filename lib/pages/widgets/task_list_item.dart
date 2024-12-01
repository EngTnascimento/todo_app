import 'package:todo_app/database/handler.dart';
import 'package:todo_app/database/schemas/category.dart';
import 'package:todo_app/pages/edit_task.page.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/database/schemas/task.dart';
import 'package:intl/intl.dart';

class TaskListItem extends StatefulWidget {
  final Task task;
  final Function onDeleteTask;
  final Function onTaskEdited;
  final Function onTaskCompleted;

  const TaskListItem(
      {super.key,
      required this.task,
      required this.onDeleteTask,
      required this.onTaskEdited,
      required this.onTaskCompleted});

  @override
  _TaskListItemState createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    DatabaseHandler db = DatabaseHandler();
    List<Category> categories = await db.getCategoriesByTask(widget.task.id!);
    print('Loading categories from task: ${widget.task.id}');
    print('category count: ${categories.length}');
    for (var category in categories) {
      print('category: ${category.name}');
      print('category id: ${category.id}');
    }
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _editTask() async {
    widget.onTaskEdited();
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    bool isOverdue = widget.task.dueDate.isBefore(today);
    bool isDueDateToday = widget.task.dueDate.year == today.year &&
        widget.task.dueDate.month == today.month &&
        widget.task.dueDate.day == today.day;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.task),
            title: Text(widget.task.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text(widget.task.description,
                style: const TextStyle(fontSize: 16)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date text
                isOverdue
                    ? Text(
                        DateFormat('MMM dd, yyyy').format(widget.task.dueDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      )
                    : Text(
                        DateFormat('MMM dd, yyyy').format(widget.task.dueDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 47, 46, 46),
                        ),
                      ),
                // Task box
                const SizedBox(width: 8),
                isOverdue
                    ? const Icon(
                        Icons.alarm,
                        color: Colors.red,
                        semanticLabel: 'Task Overdue',
                      )
                    : Container(),
                isDueDateToday
                    ? const Icon(
                        Icons.today,
                        color: Colors.grey,
                        semanticLabel: 'Today',
                      )
                    : Container(),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskPage(
                          task: widget.task,
                          onTaskEdited: _editTask,
                        ),
                      ),
                    );
                  },
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    widget.onDeleteTask(widget.task);
                  },
                ),
                Checkbox(
                  value: false,
                  onChanged: (bool? value) async {
                    if (value!) {
                      widget.onTaskCompleted(Task(
                        id: widget.task.id,
                        userId: widget.task.userId,
                        title: widget.task.title,
                        description: widget.task.description,
                        dueDate: widget.task.dueDate,
                        isCompleted: true,
                      ));
                    }
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.start,
              children: [
                for (var category in _categories)
                  Chip(
                    label: Text(category.name),
                    backgroundColor: {
                      'Red': const Color.fromARGB(255, 232, 135, 128),
                      'Green': const Color.fromARGB(255, 162, 233, 164),
                      'Blue': const Color.fromARGB(255, 166, 210, 246),
                    }[category.name]!,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
