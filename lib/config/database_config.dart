// lib/config/database_config.dart
class DatabaseConfig {
  static const String databaseName = 'skills_audit.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String usersTable = 'users';
  static const String skillsTable = 'skills';
  static const String assessmentsTable = 'assessments';
  static const String notificationsTable = 'notifications';
  static const String settingsTable = 'settings';
  
  // SQL Scripts
  static const String createUsersTable = '''
    CREATE TABLE $usersTable (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      employee_id TEXT UNIQUE NOT NULL,
      department TEXT NOT NULL,
      role TEXT NOT NULL,
      profile_picture TEXT,
      phone_number TEXT,
      position TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sync_status INTEGER DEFAULT 0
    )
  ''';
  
  static const String createSkillsTable = '''
    CREATE TABLE $skillsTable (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      proficiency TEXT NOT NULL,
      description TEXT,
      certifications TEXT,
      last_assessed TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sync_status INTEGER DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES $usersTable (id)
    )
  ''';
  
  static const String createAssessmentsTable = '''
    CREATE TABLE $assessmentsTable (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      skill_id TEXT NOT NULL,
      score INTEGER,
      status TEXT NOT NULL,
      completed_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      sync_status INTEGER DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES $usersTable (id),
      FOREIGN KEY (skill_id) REFERENCES $skillsTable (id)
    )
  ''';
  
  static const String createNotificationsTable = '''
    CREATE TABLE $notificationsTable (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      title TEXT NOT NULL,
      message TEXT NOT NULL,
      type TEXT NOT NULL,
      is_read INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $usersTable (id)
    )
  ''';
  
  static const String createSettingsTable = '''
    CREATE TABLE $settingsTable (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';
}