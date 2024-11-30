import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:desafio_login/database/schemas/user.dart';
import 'package:desafio_login/database/schemas/task.dart';

class DatabaseHandler {
  static const String _databaseName = 'user_credentials.db';
  static const int _version = 4;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    // User table
    await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    // Task table
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        due_date TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Drop the old table
      await db.execute('''
        DROP TABLE IF EXISTS users
      ''');

      // Create the new table
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');

      await db.execute('''
        DROP TABLE IF EXISTS tasks
      ''');

      // Create the new table
      await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          due_date TEXT NOT NULL,
          is_completed INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    }
  }

  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toJson());
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users',
        columns: ['id', 'email', 'password'],
        where: 'email = ?',
        whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<void> addTask(Task task) async {
    Database db = await database;
    await db.insert('tasks', {
      'user_id': task.userId,
      'title': task.title,
      'description': task.description,
      'due_date': task.dueDate.toIso8601String(),
      'is_completed': task.isCompleted ? 1 : 0,
    });
  }

  Future<List<Task>> getTasks(int userId) async {
    print('userId: $userId');
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('tasks',
        where: 'user_id = ? AND is_completed = 0', whereArgs: [userId]);
    print('maps: $maps');
    return maps.map((map) => Task.fromJson(map)).toList();
  }

  Future<void> editTask(Task task) async {
    print('Updating task: ${task.toJson()}');
    Database db = await database;
    await db.update(
        'tasks',
        {
          'title': task.title,
          'description': task.description,
          'due_date': task.dueDate.toIso8601String(),
          'is_completed': task.isCompleted ? 1 : 0
        },
        where: 'id = ?',
        whereArgs: [task.id]);
  }

  Future<void> deleteTask(Task task) async {
    Database db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [task.id]);
  }
}
