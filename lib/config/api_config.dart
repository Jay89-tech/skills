// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'https://api.skillsaudit.gov.za/v1';
  static const String apiVersion = 'v1';
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  
  static const String usersEndpoint = '/users';
  static const String skillsEndpoint = '/skills';
  static const String assessmentsEndpoint = '/assessments';
  static const String departmentsEndpoint = '/departments';
  static const String notificationsEndpoint = '/notifications';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}