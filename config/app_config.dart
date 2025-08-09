// lib/config/app_config.dart
class AppConfig {
  static const String appName = 'National Treasury Skills Audit';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // Environment
  static const String environment = 'production'; // development, staging, production
  
  // Features
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePushNotifications = true;
  
  // Database
  static const String databaseName = 'skills_audit.db';
  static const int databaseVersion = 1;
  
  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  // UI
  static const double defaultPadding = 16.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 8.0;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  static bool get isDebug => environment == 'development';
  static bool get isProduction => environment == 'production';
}
