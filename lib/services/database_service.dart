import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'gate_planner.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE subject_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT, subject TEXT, topic TEXT, timeSpent REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE mock_tests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT, score REAL, total REAL, platform TEXT, rank TEXT, notes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE pyq_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT, year INTEGER, attempted INTEGER, correct INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE daily_stats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT UNIQUE, slotsCompleted INTEGER, hoursStudied REAL
          )
        ''');
      },
    );
  }

  Database get db => _db!;

  // Subject Logs
  Future<void> insertSubjectLog(SubjectLog log) async {
    await db.insert('subject_logs', log.toMap());
  }

  Future<List<SubjectLog>> getSubjectLogs({String? subject, String? date}) async {
    String where = '';
    List<dynamic> args = [];
    if (subject != null) { where = 'subject = ?'; args.add(subject); }
    if (date != null) {
      where = where.isEmpty ? 'date = ?' : '$where AND date = ?';
      args.add(date);
    }
    final maps = await db.query('subject_logs',
      where: where.isEmpty ? null : where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'id DESC',
    );
    return maps.map((m) => SubjectLog(
      id: m['id'] as int,
      date: m['date'] as String,
      subject: m['subject'] as String,
      topic: m['topic'] as String,
      timeSpent: m['timeSpent'] as double,
    )).toList();
  }

  // Mock Tests
  Future<void> insertMockTest(MockTest test) async {
    await db.insert('mock_tests', test.toMap());
  }

  Future<List<MockTest>> getMockTests() async {
    final maps = await db.query('mock_tests', orderBy: 'date DESC');
    return maps.map((m) => MockTest(
      id: m['id'] as int,
      date: m['date'] as String,
      score: m['score'] as double,
      total: m['total'] as double,
      platform: m['platform'] as String,
      rank: m['rank'] as String?,
      notes: m['notes'] as String? ?? '',
    )).toList();
  }

  // PYQ Entries
  Future<void> insertPYQEntry(PYQEntry entry) async {
    await db.insert('pyq_entries', entry.toMap());
  }

  Future<List<PYQEntry>> getPYQEntries() async {
    final maps = await db.query('pyq_entries', orderBy: 'subject, year');
    return maps.map((m) => PYQEntry(
      id: m['id'] as int,
      subject: m['subject'] as String,
      year: m['year'] as int,
      attempted: m['attempted'] as int,
      correct: m['correct'] as int,
    )).toList();
  }

  // Daily stats for heatmap
  Future<void> saveDailyStats(String date, int slotsCompleted, double hours) async {
    await db.insert('daily_stats', {
      'date': date,
      'slotsCompleted': slotsCompleted,
      'hoursStudied': hours,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getDailyStats() async {
    return db.query('daily_stats', orderBy: 'date DESC', limit: 90);
  }

  Future<Map<String, double>> getWeeklyHours() async {
    final result = <String, double>{};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      final rows = await db.query('daily_stats', where: 'date = ?', whereArgs: [key]);
      result[key] = rows.isNotEmpty ? (rows.first['hoursStudied'] as double) : 0.0;
    }
    return result;
  }
}
