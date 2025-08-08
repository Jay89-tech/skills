class Skill {
  final String id;
  final String userId;
  final String name;
  final SkillCategory category;
  final ProficiencyLevel proficiency;
  final String? description;
  final List<String>? certifications;
  final DateTime? lastAssessed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Skill({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.proficiency,
    this.description,
    this.certifications,
    this.lastAssessed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      category: SkillCategory.values.firstWhere((e) => e.toString().split('.').last == json['category']),
      proficiency: ProficiencyLevel.values.firstWhere((e) => e.toString().split('.').last == json['proficiency']),
      description: json['description'],
      certifications: json['certifications']?.cast<String>(),
      lastAssessed: json['last_assessed'] != null ? DateTime.parse(json['last_assessed']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category.toString().split('.').last,
      'proficiency': proficiency.toString().split('.').last,
      'description': description,
      'certifications': certifications,
      'last_assessed': lastAssessed?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}