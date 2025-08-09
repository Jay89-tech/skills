// lib/models/assessment_model.dart
import '../utils/enums.dart';

class Assessment {
  final String id;
  final String userId;
  final String skillId;
  final int? score;
  final AssessmentStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? answers;
  final String? feedback;

  Assessment({
    required this.id,
    required this.userId,
    required this.skillId,
    this.score,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.answers,
    this.feedback,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'],
      userId: json['user_id'],
      skillId: json['skill_id'],
      score: json['score'],
      status: AssessmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      answers: json['answers'],
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'skill_id': skillId,
      'score': score,
      'status': status.toString().split('.').last,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'answers': answers,
      'feedback': feedback,
    };
  }
  
  Assessment copyWith({
    String? id,
    String? userId,
    String? skillId,
    int? score,
    AssessmentStatus? status,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? answers,
    String? feedback,
  }) {
    return Assessment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      skillId: skillId ?? this.skillId,
      score: score ?? this.score,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answers: answers ?? this.answers,
      feedback: feedback ?? this.feedback,
    );
  }
}