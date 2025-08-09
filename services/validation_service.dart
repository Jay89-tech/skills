/ lib/services/validation_service.dart
class ValidationService {
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  // Email validation
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}
  );
    return emailRegex.hasMatch(email.trim());
  }

  // Password validation
  ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(false, 'Password is required');
    }
    
    if (password.length < 8) {
      return ValidationResult(false, 'Password must be at least 8 characters long');
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult(false, 'Password must contain at least one uppercase letter');
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      return ValidationResult(false, 'Password must contain at least one lowercase letter');
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult(false, 'Password must contain at least one number');
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return ValidationResult(false, 'Password must contain at least one special character');
    }
    
    return ValidationResult(true, 'Password is valid');
  }

  // Name validation
  bool isValidName(String name) {
    final nameRegex = RegExp(r'^[a-zA-Z\s]{2,50}
  );
    return nameRegex.hasMatch(name.trim());
  }

  // Employee ID validation
  bool isValidEmployeeId(String employeeId) {
    final idRegex = RegExp(r'^[A-Z0-9]{6,10}
  );
    return idRegex.hasMatch(employeeId.trim().toUpperCase());
  }

  // Phone number validation
  bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}
  );
    return phoneRegex.hasMatch(phoneNumber.trim().replaceAll(RegExp(r'[\s-()]'), ''));
  }

  // Skill name validation
  bool isValidSkillName(String skillName) {
    if (skillName.trim().isEmpty) return false;
    if (skillName.length < 2 || skillName.length > 100) return false;
    
    final skillRegex = RegExp(r'^[a-zA-Z0-9\s\-\+\#\.]+
  );
    return skillRegex.hasMatch(skillName.trim());
  }

  // Description validation
  bool isValidDescription(String description) {
    return description.length <= 500;
  }

  // Generic text validation
  ValidationResult validateRequiredField(String value, String fieldName, {int? minLength, int? maxLength}) {
    if (value.trim().isEmpty) {
      return ValidationResult(false, '$fieldName is required');
    }
    
    if (minLength != null && value.trim().length < minLength) {
      return ValidationResult(false, '$fieldName must be at least $minLength characters long');
    }
    
    if (maxLength != null && value.trim().length > maxLength) {
      return ValidationResult(false, '$fieldName must not exceed $maxLength characters');
    }
    
    return ValidationResult(true, '$fieldName is valid');
  }

  // Confirm password validation
  ValidationResult validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return ValidationResult(false, 'Please confirm your password');
    }
    
    if (password != confirmPassword) {
      return ValidationResult(false, 'Passwords do not match');
    }
    
    return ValidationResult(true, 'Passwords match');
  }
}

class ValidationResult {
  final bool isValid;
  final String message;

  ValidationResult(this.isValid, this.message);
}
