// lib/models/department_model.dart
class Department {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? headOfDepartment;
  final int employeeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Department({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.headOfDepartment,
    required this.employeeCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      headOfDepartment: json['head_of_department'],
      employeeCount: json['employee_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'head_of_department': headOfDepartment,
      'employee_count': employeeCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}