import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/models/task_model.dart';

class DatabaseHelper {
  String _dbName = "Task.db";
  int _dbVersion = 1;

  DatabaseHelper.private();

  static final DatabaseHelper instance = DatabaseHelper.private();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await _initDB();
    return _db;
  }

  _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String dbPath = join(dir.toString(), _dbName);
    return await openDatabase(dbPath,
        version: _dbVersion, onCreate: _onCreateDb);
  }

  _onCreateDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${Task.tblName}(
    ${Task.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${Task.colTitle} TEXT,
    ${Task.colDate} TEXT,
    ${Task.colPriority} TEXT,
    ${Task.colStatus} INTEGER
    )
    ''');
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.db;
    return await db.insert(Task.tblName, task.toMap());
  }

  Future<List<Task>> fetchTask() async {
    Database db = await this.db;
    final List<Map> tasks = await db.query(Task.tblName);
    final List<Task> tasksList =
        tasks.length == 0 ? [] : tasks.map((e) => Task.fromMap(e)).toList();
    tasksList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return tasksList;
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(Task.tblName);
    return result;
  }

  Future updateTask(Task task) async {
    Database db = await this.db;
    return await db.update(Task.tblName, task.toMap(),
        where: '${Task.colId} = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    return await db
        .delete(Task.tblName, where: '${Task.colId} = ?', whereArgs: [id]);
  }
}
