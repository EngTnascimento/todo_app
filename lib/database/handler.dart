import 'package:todo_app/database/schemas/category.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:todo_app/database/schemas/user.dart';
import 'package:todo_app/database/schemas/task.dart';

class DatabaseHandler {
  static const String _databaseName = 'user_credentials.db';
  static const int _version = 2;

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
          password TEXT NOT NULL,
          dark_theme INTEGER NOT NULL
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

    // categories x tasks table
    await db.execute('''
        CREATE TABLE task_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          task_id INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (task_id) REFERENCES tasks (id),
          FOREIGN KEY (category_id) REFERENCES category_list (id)
        )
      ''');

    // categories list table
    await db.execute('''
        CREATE TABLE category_list (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          user_id INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('''
        DROP TABLE IF EXISTS users
      ''');

      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          dark_theme INTEGER NOT NULL
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

      await db.execute('''
        DROP TABLE IF EXISTS task_categories
      ''');

      await db.execute('''
        CREATE TABLE task_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          task_id INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (task_id) REFERENCES tasks (id),
          FOREIGN KEY (category_id) REFERENCES category_list (id)
        )
      ''');

      await db.execute('''
        DROP TABLE IF EXISTS category_list
      ''');

      await db.execute('''
        CREATE TABLE category_list (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          user_id INTEGER NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    }
  }

  Future<int> insertUser(User user) async {
    Database db = await database;
    int userId = await db.insert('users', user.toJson());
    await db.insert('category_list', {'name': 'Red', 'user_id': userId});
    await db.insert('category_list', {'name': 'Blue', 'user_id': userId});
    await db.insert('category_list', {'name': 'Green', 'user_id': userId});
    return userId;
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

  Future<int> addTask(Task task) async {
    Database db = await database;
    int id = await db.insert('tasks', task.toJson());
    return id;
  }

  Future<List<Task>> getTasks(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('tasks',
        where: 'user_id = ? AND is_completed = 0', whereArgs: [userId]);
    return maps.map((map) => Task.fromJson(map)).toList();
  }

  Future<void> editTask(Task task) async {
    Database db = await database;
    await db
        .update('tasks', task.toJson(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(Task task) async {
    Database db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> createCategory(Category category) async {
    Database db = await database;
    await db.insert('category_list', category.toJson());
  }

  Future<void> deleteCategory(Category category) async {
    Database db = await database;
    await db.delete('categories',
        where: 'id = ? AND user_id = ?',
        whereArgs: [category.id, category.userId]);
  }

  Future<List<Category>> getCategoriesByUser(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db
        .query('category_list', where: 'user_id = ?', whereArgs: [userId]);
    return maps.map((map) => Category.fromJson(map)).toList();
  }

  Future<List<Category>> getCategoriesByTask(int taskId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT cl.* 
    FROM task_categories tc 
    JOIN category_list cl ON tc.category_id = cl.id 
    WHERE tc.task_id = ?
  ''', [taskId]);
    return maps.map((map) => Category.fromJson(map)).toList();
  }

  Future<void> removeCategoryFromTask(int taskId, Category category) async {
    Database db = await database;
    await db.delete('task_categories',
        where: 'user_id = ? AND task_id = ? AND category_id = ?',
        whereArgs: [category.userId, taskId, category.id]);
  }

  Future<void> attachCateoriesToTask(
      List<Category> categories, int taskId) async {
    Database db = await database;
    for (var category in categories) {
      await db.insert('task_categories', {
        'user_id': category.userId,
        'task_id': taskId,
        'category_id': category.id
      });
    }
  }

  Future<void> updateCategoriesToTask(
      List<Category> categories, Task task) async {
    Database db = await database;
    await db
        .delete('task_categories', where: 'task_id = ?', whereArgs: [task.id]);
    for (var category in categories) {
      await db.insert('task_categories', {
        'user_id': category.userId,
        'task_id': task.id,
        'category_id': category.id
      });
    }
  }
}
