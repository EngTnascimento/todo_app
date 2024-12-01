import 'package:todo_app/database/schemas/task.dart';
import 'package:flutter/material.dart';

class SearchTask extends StatefulWidget {
  final Function onSearch;
  final List<Task> tasks;

  const SearchTask({required this.onSearch, required this.tasks});

  @override
  _SearchTaskState createState() => _SearchTaskState();
}

class _SearchTaskState extends State<SearchTask> {
  final TextEditingController _searchController = TextEditingController();
  List<Task> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _filteredTasks = widget.tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (text) {
          _filteredTasks = widget.tasks
              .where((task) =>
                  task.title.toLowerCase().contains(text.toLowerCase()))
              .toList();
          widget.onSearch(_filteredTasks);
        },
      ),
    );
  }
}
