class AppConstants {
  // App Info
  static const String appName = 'National Treasury Skills Audit';
  static const String appVersion = '1.0.0';
  
  // API
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String appSettingsKey = 'app_settings';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxSkillNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
}