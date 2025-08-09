import '../services/api_service.dart';
import '../models/skill_model.dart';
import '../utils/enums.dart';

class SkillController {
  final ApiService _apiService = ApiService();

  Future<List<Skill>> getUserSkills(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/skills');
      return (response.data['skills'] as List)
          .map((skillJson) => Skill.fromJson(skillJson))
          .toList();
    } catch (e) {
      throw Exception('Failed to load skills: $e');
    }
  }

  Future<Skill> createSkill(Skill skill) async {
    try {
      final response = await _apiService.post('/skills', data: skill.toJson());
      return Skill.fromJson(response.data['skill']);
    } catch (e) {
      throw Exception('Failed to create skill: $e');
    }
  }

  Future<Skill> updateSkill(Skill skill) async {
    try {
      final response = await _apiService.put('/skills/${skill.id}', data: skill.toJson());
      return Skill.fromJson(response.data['skill']);
    } catch (e) {
      throw Exception('Failed to update skill: $e');
    }
  }

  Future<bool> deleteSkill(String skillId) async {
    try {
      await _apiService.delete('/skills/$skillId');
      return true;
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }

  Future<List<String>> getSkillSuggestions(String query) async {
    try {
      final response = await _apiService.get('/skills/suggestions?q=$query');
      return List<String>.from(response.data['suggestions']);
    } catch (e) {
      return [];
    }
  }

  bool validateSkill(String name, SkillCategory category, ProficiencyLevel proficiency) {
    if (name.trim().isEmpty) return false;
    if (name.length < 2) return false;
    return true;
  }

  String getProficiencyDescription(ProficiencyLevel level) {
    switch (level) {
      case ProficiencyLevel.beginner:
        return 'Basic understanding and limited experience';
      case ProficiencyLevel.intermediate:
        return 'Good working knowledge with some experience';
      case ProficiencyLevel.advanced:
        return 'Strong expertise with extensive experience';
      case ProficiencyLevel.expert:
        return 'Recognized authority with deep knowledge';
    }
  }
}