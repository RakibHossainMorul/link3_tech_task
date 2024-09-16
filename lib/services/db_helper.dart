import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE task_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        FOREIGN KEY (group_id) REFERENCES task_groups(id) ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // CRUD for Task Groups
  Future<int> createTaskGroup(Map<String, dynamic> group) async {
    final db = await instance.database;
    return await db.insert('task_groups', group);
  }

  Future<List<Map<String, dynamic>>> getTaskGroups() async {
    final db = await instance.database;
    return await db.query('task_groups');
  }

  Future<int> deleteTaskGroup(int id) async {
    final db = await instance.database;
    return await db.delete('task_groups', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD for Tasks
  Future<int> createTask(Map<String, dynamic> task) async {
    final db = await instance.database;
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> getTasks(int groupId) async {
    final db = await instance.database;
    return await db.query('tasks', where: 'group_id = ?', whereArgs: [groupId]);
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Add this updateTask function
  Future<int> updateTask(int taskId, Map<String, dynamic> updatedTask) async {
    final db = await instance.database;

    // Use update method for specific task id
    return await db.update(
      'tasks',
      updatedTask,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<int> getTaskCountForGroup(int groupId) async {
    final db = await instance.database;
    final countQuery = await db.rawQuery(
        'SELECT COUNT(*) FROM tasks WHERE group_id = ?',
        [groupId]
    );
    int count = Sqflite.firstIntValue(countQuery) ?? 0;
    return count;
  }


}
