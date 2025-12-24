import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/symptom_report.dart';
import 'dart:convert';

class OfflineService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'carebridge.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE symptom_reports (
            id TEXT PRIMARY KEY,
            patientId TEXT,
            timestamp TEXT,
            symptoms TEXT,
            attachments TEXT,
            isSynced INTEGER,
            severity TEXT
          )
        ''');
        
        await db.execute('''
          CREATE TABLE care_plans (
            id TEXT PRIMARY KEY,
            patientId TEXT,
            data TEXT
          )
        ''');
      },
    );
  }

  // Cache symptom report locally
  Future<void> saveSymptomReportOffline(SymptomReport report) async {
    final db = await database;
    await db.insert(
      'symptom_reports',
      {
        'id': report.id,
        'patientId': report.patientId,
        'timestamp': report.timestamp.toIso8601String(),
        'symptoms': json.encode(report.symptoms),
        'attachments': json.encode(report.attachments ?? []),
        'isSynced': report.isSynced ? 1 : 0,
        'severity': report.severity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get unsynced reports
  Future<List<SymptomReport>> getUnsyncedReports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'symptom_reports',
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return SymptomReport(
        id: maps[i]['id'],
        patientId: maps[i]['patientId'],
        timestamp: DateTime.parse(maps[i]['timestamp']),
        symptoms: json.decode(maps[i]['symptoms']),
        attachments: List<String>.from(json.decode(maps[i]['attachments'])),
        isSynced: maps[i]['isSynced'] == 1,
        severity: maps[i]['severity'],
      );
    });
  }

  // Mark report as synced
  Future<void> markAsSynced(String reportId) async {
    final db = await database;
    await db.update(
      'symptom_reports',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  // Cache care plan
  Future<void> savCarePlanOffline(String patientId, String carePlanData) async {
    final db = await database;
    await db.insert(
      'care_plans',
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'patientId': patientId,
        'data': carePlanData,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
