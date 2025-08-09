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
}// lib/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';

class ProfileController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  final FileService _fileService = FileService();
  
  User? _currentUser;
  List<Skill> _userSkills = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get currentUser => _currentUser;
  List<Skill> get userSkills => _userSkills;
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
  
  Future<bool> loadProfile() async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Load user profile
      final userResponse = await _apiService.get('/user/profile');
      _currentUser = User.fromJson(userResponse.data['user']);
      
      // Load user skills
      final skillsResponse = await _apiService.get('/users/${_currentUser!.id}/skills');
      _userSkills = (skillsResponse.data['skills'] as List)
          .map((skillData) => Skill.fromJson(skillData))
          .toList();
      
      // Save to local database
      await _databaseService.saveUser(_currentUser!);
      for (var skill in _userSkills) {
        await _databaseService.saveSkill(skill);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to load profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.put('/user/profile', data: userData);
      _currentUser = User.fromJson(response.data['user']);
      
      // Update local database
      await _databaseService.saveUser(_currentUser!);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _apiService.put('/user/password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      
      return true;
    } catch (e) {
      _setError('Failed to change password: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> uploadProfilePicture() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final imagePath = await _fileService.pickImage();
      if (imagePath == null) {
        _setLoading(false);
        return false;
      }
      
      // In a real app, you'd upload to a server
      // For now, we'll just update the user locally
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(profilePicture: imagePath);
        await _databaseService.saveUser(_currentUser!);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Failed to upload profile picture: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> addSkill(Skill skill) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.post('/skills', data: skill.toJson());
      final newSkill = Skill.fromJson(response.data['skill']);
      
      _userSkills.add(newSkill);
      await _databaseService.saveSkill(newSkill);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add skill: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateSkill(Skill skill) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.put('/skills/${skill.id}', data: skill.toJson());
      final updatedSkill = Skill.fromJson(response.data['skill']);
      
      final index = _userSkills.indexWhere((s) => s.id == skill.id);
      if (index != -1) {
        _userSkills[index] = updatedSkill;
        await _databaseService.saveSkill(updatedSkill);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update skill: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> deleteSkill(String skillId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _apiService.delete('/skills/$skillId');
      
      _userSkills.removeWhere((skill) => skill.id == skillId);
      await _databaseService.deleteSkill(skillId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete skill: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  void clearError() {
    _setError(null);
  }
  
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}