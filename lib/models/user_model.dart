// lib/models/user_model.dart
import '../utils/enums.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String employeeId;
  final String department;
  final UserRole role;
  final String? profilePicture;
  final String? phoneNumber;
  final String? position;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.employeeId,
    required this.department,
    required this.role,
    this.profilePicture,
    this.phoneNumber,
    this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      employeeId: json['employee_id'],
      department: json['department'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      profilePicture: json['profile_picture'],
      phoneNumber: json['phone_number'],
      position: json['position'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'employee_id': employeeId,
      'department': department,
      'role': role.toString().split('.').last,
      'profile_picture': profilePicture,
      'phone_number': phoneNumber,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? department,
    String? profilePicture,
    String? phoneNumber,
    String? position,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      employeeId: employeeId,
      department: department ?? this.department,
      role: role,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      position: position ?? this.position,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}