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
      case ProficiencyLevel.intermediate:
        return Icons.star_half;
      case ProficiencyLevel.advanced:
        return Icons.star;
      case ProficiencyLevel.expert:
        return Icons.star_rate;
    }
  }

  static String getUserRoleName(UserRole role) {
    switch (role) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  static String getNotificationTypeName(NotificationType type) {
    switch (type) {
      case NotificationType.skillReminder:
        return 'Skill Reminder';
      case NotificationType.assessmentDue:
        return 'Assessment Due';
      case NotificationType.systemUpdate:
        return 'System Update';
      case NotificationType.announcement:
        return 'Announcement';
    }
  }

  static IconData getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.skillReminder:
        return Icons.reminder;
      case NotificationType.assessmentDue:
        return Icons.assignment_late;
      case NotificationType.systemUpdate:
        return Icons.system_update;
      case NotificationType.announcement:
        return Icons.campaign;
    }
  }

  static Color getAssessmentStatusColor(AssessmentStatus status) {
    switch (status) {
      case AssessmentStatus.pending:
        return Colors.orange;
      case AssessmentStatus.inProgress:
        return Colors.blue;
      case AssessmentStatus.completed:
        return Colors.green;
      case AssessmentStatus.expired:
        return Colors.red;
    }
  }

  static String getAssessmentStatusName(AssessmentStatus status) {
    switch (status) {
      case AssessmentStatus.pending:
        return 'Pending';
      case AssessmentStatus.inProgress:
        return 'In Progress';
      case AssessmentStatus.completed:
        return 'Completed';
      case AssessmentStatus.expired:
        return 'Expired';
    }
  }

  // Validation helpers
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Number formatting
  static String formatNumber(num number, {int decimals = 0}) {
    final formatter = NumberFormat.decimalPattern();
    if (decimals > 0) {
      return formatter.format(number.toStringAsFixed(decimals));
    }
    return formatter.format(number);
  }

  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }
}