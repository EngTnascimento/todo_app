import 'package:todo_app/database/handler.dart';
import 'package:todo_app/database/schemas/category.dart';
import 'package:todo_app/pages/edit_task.page.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/database/schemas/task.dart';
import 'package:intl/intl.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final Function onDeleteTask;
  final Function onTaskEdited;
  final Function onTaskCompleted;
  final List<Category> categories;

  TaskListItem(
      {required this.task,
      required this.onDeleteTask,
      required this.onTaskEdited,
      required this.onTaskCompleted,
      required this.categories});

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    bool isOverdue = task.dueDate.isBefore(today);
    bool isDueDateToday = task.dueDate.year == today.year &&
        task.dueDate.month == today.month &&
        task.dueDate.day == today.day;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.task),
            title: Text(task.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text(task.description, style: TextStyle(fontSize: 16)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date text
                isOverdue
                    ? Text(
                        DateFormat('MMM dd, yyyy').format(task.dueDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      )
                    : Text(
                        DateFormat('MMM dd, yyyy').format(task.dueDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 47, 46, 46),
                        ),
                      ),
                // Task box
                SizedBox(width: 8),
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
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskPage(
                          task: task,
                          onTaskEdited: onTaskEdited,
                        ),
                      ),
                    );
                  },
                ),
                // Delete button
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    onDeleteTask(task);
                  },
                ),
                Checkbox(
                  value: false,
                  onChanged: (bool? value) async {
                    if (value!) {
                      onTaskCompleted(Task(
                        id: task.id,
                        userId: task.userId,
                        title: task.title,
                        description: task.description,
                        dueDate: task.dueDate,
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
                for (var category in categories)
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
          Divider(),
        ],
      ),
    );
  }
}
