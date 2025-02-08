import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_loop/data/task.dart';

class TaskDatabaseHelper {
  static final TaskDatabaseHelper _instance = TaskDatabaseHelper._internal();

  factory TaskDatabaseHelper() => _instance;

  TaskDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT)',
      );
      await db.insert('metadata', {
        'key': 'lastday',
        'value': '',
      });

      await db.execute(
        'CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, position INTEGER, title TEXT, time INTEGER, days INTEGER, isNew INTEGER, isChecked INTEGER, doneCounter INTEGER, showedCounter INTEGER)',
      );
      for (int index = 0; index < _defaultTasks.length; index++) {
        var task = _defaultTasks[index];
        task.position = index;
        int id = await db.insert('tasks', task.toMap());
        task.id = id;
      }
    });
  }

  Future<void> checkTask(Task task, bool checked) async {
    final db = await database;
    await db.update(
      'tasks',
      {'isChecked': checked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> updateTask(Task task) async {
    final db = await database;

    if (task.id != null) {
      await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } else {
      int id = await db.insert(
        'tasks',
        task.toMap(),
      );
      task.id = id;
    }
  }

  Future<void> deleteTask(int taskId) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: 'position ASC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<DateTime?> _getLastDay() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'metadata',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['lastday'],
    );

    String? date = result.isNotEmpty ? result.first['value'] as String? : null;
    return date != null ? DateTime.tryParse(date) : null;
  }

  Future<void> _setLastDay(DateTime lastDay) async {
    final db = await database;
    await db.update(
      'metadata',
      {'value': lastDay.toIso8601String()},
      where: 'key = ?',
      whereArgs: ['lastday'],
    );
  }

  Future<List<Task>> getTasksForToday() async {
    DateTime today = DateTime.now();
    DateTime? lastDay = await _getLastDay();
    await _setLastDay(today);
    bool isNewDay = lastDay == null || !isSameDay(today, lastDay);

    final List<Task> tasks =
        (await getTasks()).where((task) => task.isActive(today)).toList();

    for (var task in tasks) {
      if (task.isNew || isNewDay) {
        task.isNew = false;
        if (task.isChecked) task.doneCounter += 1;
        task.isChecked = false;
        task.showedCounter += 1;

        await updateTask(task);
      }
    }

    return tasks;
  }

  static final List<Task> _defaultTasks = [
    Task(
        title: 'Wake Up',
        days: List.generate(7, (i) => false),
        time: const Duration(hours: 6, minutes: 30)),
    Task(title: 'Workout', days: List.generate(7, (i) => false)),
    Task(title: 'Meditate', days: List.generate(7, (i) => false)),
  ];

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
