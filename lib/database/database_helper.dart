import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';
import '../pages/search.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        lastModified TEXT NOT NULL,
        color TEXT,
        tag TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 버전 2에서 추가된 lastModified 컬럼
      await db.execute('ALTER TABLE todos ADD COLUMN lastModified TEXT');
      print('Database upgraded to version 2: lastModified column added.');
    }
  }

  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');

    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'] ?? '',
        description: maps[i]['description'] ?? '',
        isCompleted: maps[i]['isCompleted'] == 1,
        createdAt: DateTime.parse(maps[i]['createdAt']),
        lastModified: maps[i]['lastModified'] != null
            ? DateTime.parse(maps[i]['lastModified'])
            : DateTime.now(),
        color: maps[i]['color'] ?? 'blue',
        tag: maps[i]['tag'], // 기본� 제거, null 허용
      );
    });
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Todo>> searchTodos(String query) async {
    final db = await database;
    final results = await db.query(
      'todos',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return results.map((map) => Todo.fromMap(map)).toList();
  }

  Future<List<Todo>> searchTodosWithInitials(String query) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query('todos');
    return results.map((map) => Todo.fromMap(map)).where((todo) {
      final titleInitials = extractInitials(todo.title);
      final descriptionInitials = extractInitials(todo.description);
      return todo.title.contains(query) ||
          todo.description.contains(query) ||
          titleInitials.contains(query) ||
          descriptionInitials.contains(query);
    }).toList();
  }

  // 최근 동기화 시간 가져오기
  Future<DateTime> getLastSyncTime() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT MAX(lastModified) as lastSync FROM todos');
    final lastSync = result.first['lastSync'];
    return lastSync != null
        ? DateTime.parse(lastSync as String)
        : DateTime.fromMillisecondsSinceEpoch(0);
  }

  // 수정된 데이터 가져오기
  Future<List<Todo>> getModifiedTodos() async {
    final db = await database;
    final results = await db.query('todos',
        where: 'lastModified > ?', whereArgs: [getLastSyncTime()]);
    return results.map((map) => Todo.fromMap(map)).toList();
  }

  // 데이터 삽입 또는 업데이트
  Future<void> insertOrUpdateTodo(Todo todo) async {
    final db = await database;
    await db.insert('todos', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteAllTodos() async {
    final db = await database;
    await db.delete('todos'); // todos 테이블의 모든 데이터 삭제
  }
}
