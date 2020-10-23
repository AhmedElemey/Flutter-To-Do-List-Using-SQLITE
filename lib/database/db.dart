import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:todoapp/database/todo_item.dart';

abstract class DB {
  static Database _db;
  static int get _version => 1;
  static Future<void> init() async {
    try {
      String _path = await getDatabasesPath();
      String _databasePath = p.join(_path, 'todolist.db');
      _db = await openDatabase(_databasePath,
          version: _version, onCreate: onCreate);
    } catch (ex) {
      print(ex);
    }
  }

  static Future<void> onCreate(Database db, int version) async =>
      await db.execute(
          'CREATE TABLE todo(id INTEGER PRIMARY KEY NOT NULL ,name STRING)');

  static Future<List<Map<String, dynamic>>> query(String table) async =>
      await _db.query(table);

  static Future<int> insert(String table, ToDoItem todo) async =>
      await _db.insert(table, todo.toMap());

  static Future<int> delete(String table, ToDoItem todo) async =>
      await _db.delete(table, where: 'id = ?', whereArgs: [todo.id]);
}
