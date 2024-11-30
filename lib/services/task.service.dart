import 'package:desafio_login/database/handler.dart';
import 'package:desafio_login/database/schemas/task.dart';

class TaskService {
  int currentUserId;

  TaskService(this.currentUserId);
  final DatabaseHandler _databaseHandler = DatabaseHandler();

  List<Task> tasks = [];

  Future<void> addTask(Task task) async {
    await _databaseHandler.addTask(task);
    tasks.add(task);
  }

  int getGetCurrentUserId() {
    return currentUserId;
  }

  Future<void> editTask(Task task) async {
    print(
        'editing task: title: ${task.title}, description: ${task.description}, dueDate: ${task.dueDate}');
    await _databaseHandler.editTask(task);
    tasks.removeWhere((element) => element.id == task.id);
    tasks.add(task);
  }

  Future<void> deleteTask(Task task) async {
    await _databaseHandler.deleteTask(task);
    tasks.removeWhere((element) => element.id == task.id);
  }

  Future<void> loadTasks() async {
    tasks = await _databaseHandler.getTasks(currentUserId);
    print('tasks: $tasks');
  }
}
