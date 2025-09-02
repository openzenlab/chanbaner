import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:chanbaner/models/session.dart';

class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chanbaner.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        started_at INTEGER NOT NULL,
        ended_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE reflections (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        mirror TEXT NOT NULL,
        koan TEXT NOT NULL,
        micro_practice TEXT NOT NULL,
        user_journal TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY(session_id) REFERENCES sessions(id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE iri_weekly (
        id TEXT PRIMARY KEY,
        week_start INTEGER NOT NULL,
        iri_score REAL NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }
  
  Future<void> initialize() async {
    await database;
  }
  
  Future<String> insertSession(Session session) async {
    final db = await database;
    await db.insert('sessions', session.toMap());
    return session.id;
  }
  
  Future<String> insertReflection(Reflection reflection) async {
    final db = await database;
    await db.insert('reflections', reflection.toMap());
    return reflection.id;
  }
  
  Future<List<Session>> getSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      orderBy: 'started_at DESC',
    );
    
    return List.generate(maps.length, (i) => Session.fromMap(maps[i]));
  }
  
  Future<List<Reflection>> getReflections() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reflections',
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) => Reflection.fromMap(maps[i]));
  }
  
  Future<List<Reflection>> getReflectionsForSession(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reflections',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at DESC',
    );
    
    return List.generate(maps.length, (i) => Reflection.fromMap(maps[i]));
  }
}