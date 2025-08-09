// lib/services/database_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/database_config.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';
import '../models/assessment_model.dart';
import '../models/notification_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<void> initialize() async {
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), DatabaseConfig.databaseName);
    
    return await openDatabase(
      path,
      version: DatabaseConfig.databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute(DatabaseConfig.createUsersTable);
    await db.execute(DatabaseConfig.createSkillsTable);
    await db.execute(DatabaseConfig.createAssessmentsTable);
    await db.execute(DatabaseConfig.createNotificationsTable);
    await db.execute(DatabaseConfig.createSettingsTable);
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic
    }
  }

  // User operations
  Future<void> saveUser(User user) async {
    await _database?.insert(
      DatabaseConfig.usersTable,
      {
        ...user.toJson(),
        'sync_status': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getCurrentUser() async {
    final List<Map<String, dynamic>>? maps = await _database?.query(
      DatabaseConfig.usersTable,
      limit: 1,
    );

    if (maps != null && maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<void> clearUserData() async {
    await _database?.delete(DatabaseConfig.usersTable);
    await _database?.delete(DatabaseConfig.skillsTable);
    await _database?.delete(DatabaseConfig.assessmentsTable);
    await _database?.delete(DatabaseConfig.notificationsTable);
  }

  // Skill operations
  Future<void> saveSkill(Skill skill) async {
    await _database?.insert(
      DatabaseConfig.skillsTable,
      {
        ...skill.toJson(),
        'certifications': skill.certifications != null ? json.encode(skill.certifications) : null,
        'sync_status': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Skill>> getUserSkills(String userId) async {
    final List<Map<String, dynamic>>? maps = await _database?.query(
      DatabaseConfig.skillsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps != null) {
      return maps.map((map) {
        // Convert certifications back to List<String>
        if (map['certifications'] != null) {
          map['certifications'] = List<String>.from(json.decode(map['certifications']));
        }
        return Skill.fromJson(map);
      }).toList();
    }
    return [];
  }

  Future<void> deleteSkill(String skillId) async {
    await _database?.delete(
      DatabaseConfig.skillsTable,
      where: 'id = ?',
      whereArgs: [skillId],
    );
  }

  // Assessment operations
  Future<void> saveAssessment(Assessment assessment) async {
    await _database?.insert(
      DatabaseConfig.assessmentsTable,
      {
        ...assessment.toJson(),
        'answers': assessment.answers != null ? json.encode(assessment.answers) : null,
        'sync_status': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Assessment>> getUserAssessments(String userId) async {
    final List<Map<String, dynamic>>? maps = await _database?.query(
      DatabaseConfig.assessmentsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps != null) {
      return maps.map((map) {
        // Convert answers back to Map
        if (map['answers'] != null) {
          map['answers'] = json.decode(map['answers']);
        }
        return Assessment.fromJson(map);
      }).toList();
    }
    return [];
  }

  // Notification operations
  Future<void> saveNotification(NotificationModel notification) async {
    await _database?.insert(
      DatabaseConfig.notificationsTable,
      {
        ...notification.toJson(),
        'data': notification.data != null ? json.encode(notification.data) : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final List<Map<String, dynamic>>? maps = await _database?.query(
      DatabaseConfig.notificationsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    if (maps != null) {
      return maps.map((map) {
        // Convert data back to Map
        if (map['data'] != null) {
          map['data'] = json.decode(map['data']);
        }
        return NotificationModel.fromJson(map);
      }).toList();
    }
    return [];
  }

  // Settings operations
  Future<void> saveSetting(String key, String value) async {
    await _database?.insert(
      DatabaseConfig.settingsTable,
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final List<Map<String, dynamic>>? maps = await _database?.query(
      DatabaseConfig.settingsTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (maps != null && maps.isNotEmpty) {
      return maps.first['value'];
    }
    return null;
  }

  Future<void> close() async {
    await _database?.close();
  }
}
