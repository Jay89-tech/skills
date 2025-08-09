// lib/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';

class ProfileController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FileService _fileService = FileService();
  
  User? _user;
  List<Skill> _skills = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get user => _user;
  List<Skill> get skills => _skills;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  Future<bool> loadProfile(String userId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Load user profile
      final userResponse = await _apiService.get('/users/$userId');
      _user = User.fromJson(userResponse.data['user']);
      
      // Load user skills
      final skillsResponse = await _apiService.get('/users/$userId/skills');
      _skills = (skillsResponse.data['skills'] as List)
          .map((skillData) => Skill.fromJson(skillData))
          .toList();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to load profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.put('/user/profile', data: profileData);
      _user = User.fromJson(response.data['user']);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateProfilePicture() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final imagePath = await _fileService.pickImage();
      if (imagePath != null) {
        // In a real app, you would upload to a server
        // For now, we'll just update locally
        _user = _user?.copyWith(profilePicture: imagePath);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update profile picture: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> deleteSkill(String skillId) async {
    try {
      await _apiService.delete('/skills/$skillId');
      _skills.removeWhere((skill) => skill.id == skillId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete skill: ${e.toString()}');
      return false;
    }
  }
  
  void clearError() {
    _setError(null);
  }
}