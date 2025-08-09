// lib/controllers/admin_controller.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AdminController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<User> _users = [];
  Map<String, dynamic>? _systemStats;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<User> get users => _users;
  Map<String, dynamic>? get systemStats => _systemStats;
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
  
  Future<bool> loadUsers() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.get('/admin/users');
      _users = (response.data['users'] as List)
          .map((userData) => User.fromJson(userData))
          .toList();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to load users: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> loadSystemStats() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.get('/admin/stats');
      _systemStats = response.data;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to load system stats: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _apiService.put('/admin/users/$userId/role', data: {
        'role': newRole.toString().split('.').last,
      });
      
      // Update local user list
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        // Create a new user with updated role (assuming User has a copyWith method)
        _users[userIndex] = User(
          id: _users[userIndex].id,
          name: _users[userIndex].name,
          email: _users[userIndex].email,
          employeeId: _users[userIndex].employeeId,
          department: _users[userIndex].department,
          role: newRole,
          profilePicture: _users[userIndex].profilePicture,
          phoneNumber: _users[userIndex].phoneNumber,
          position: _users[userIndex].position,
          createdAt: _users[userIndex].createdAt,
          updatedAt: DateTime.now(),
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update user role: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      await _apiService.delete('/admin/users/$userId');
      
      // Remove from local list
      _users.removeWhere((user) => user.id == userId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete user: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<Map<String, dynamic>?> generateReport(String reportType, Map<String, dynamic> filters) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.post('/admin/reports', data: {
        'type': reportType,
        'filters': filters,
      });
      
      return response.data;
    } catch (e) {
      _setError('Failed to generate report: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  void clearError() {
    _setError(null);
  }
}