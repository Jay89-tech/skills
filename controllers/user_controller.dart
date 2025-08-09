// lib/controllers/user_controller.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class UserController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get currentUser => _currentUser;
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
  
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    try {
      // Try to get from local database first
      final localUser = await _databaseService.getCurrentUser();
      if (localUser != null) {
        _currentUser = localUser;
        notifyListeners();
        return _currentUser;
      }
      
      // If not in local database, get from API
      final response = await _apiService.get('/user/profile');
      _currentUser = User.fromJson(response.data['user']);
      
      // Save to local database
      await _databaseService.saveUser(_currentUser!);
      
      notifyListeners();
      return _currentUser;
    } catch (e) {
      _setError('Failed to get user: ${e.toString()}');
      return null;
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
  
  Future<bool> uploadProfilePicture(String imagePath) async {
    _setLoading(true);
    _setError(null);
    
    try {
      // In a real app, you'd upload the file to a server
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
  
  void clearError() {
    _setError(null);
  }
}