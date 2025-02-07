import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "vehicle_cache.db");
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vehicle_cache (
            cacheKey TEXT PRIMARY KEY,
            jsonData TEXT
          )
        ''');
      },
    );
  }

  // Save JSON data
  Future<void> saveJsonData(String cacheKey, Map<String, dynamic> jsonData) async {
    final db = await database;
    await db.insert(
      'vehicle_cache',
      {'cacheKey': cacheKey, 'jsonData': jsonEncode(jsonData)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get JSON data
  Future<Map<String, dynamic>?> getJsonData(String cacheKey) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'vehicle_cache',
      where: 'cacheKey = ?',
      whereArgs: [cacheKey],
    );

    if (result.isNotEmpty) {
      return jsonDecode(result.first['jsonData']);
    }
    return null;
  }
}
