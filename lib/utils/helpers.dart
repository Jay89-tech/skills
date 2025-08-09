// lib/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/enums.dart';

class Helpers {
  // Date formatting
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(DateTime dateTime, {String pattern = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(pattern).format(dateTime);
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime, pattern: 'MMM d, yyyy');
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // String utilities
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Enum helpers
  static String getSkillCategoryName(SkillCategory category) {
    switch (category) {
      case SkillCategory.finance:
        return 'Finance';
      case SkillCategory.software:
        return 'Software';
      case SkillCategory.management:
        return 'Management';
      case SkillCategory.technology:
        return 'Technology';
      case SkillCategory.communication:
        return 'Communication';
      case SkillCategory.analytical:
        return 'Analytical';
      case SkillCategory.leadership:
        return 'Leadership';
      case SkillCategory.compliance:
        return 'Compliance';
    }
  }

  static String getProficiencyLevelName(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.beginner:
        return 'Beginner';
      case ProficiencyLevel.intermediate:
        return 'Intermediate';
      case ProficiencyLevel.advanced:
        return 'Advanced';
      case ProficiencyLevel.expert:
        return 'Expert';
    }
  }

  static Color getProficiencyLevelColor(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.beginner:
        return Colors.red;
      case ProficiencyLevel.intermediate:
        return Colors.orange;
      case ProficiencyLevel.advanced:
        return Colors.blue;
      case ProficiencyLevel.expert:
        return Colors.green;
    }
  }

  static IconData getProficiencyLevelIcon(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.beginner:
        return Icons.star_outline;
      case ProficiencyLevel.// lib/config/api_config.dart
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