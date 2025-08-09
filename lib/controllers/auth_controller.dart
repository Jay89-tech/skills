// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
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
  
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.login(email, password);
      if (result['success']) {
        _currentUser = User.fromJson(result['user']);
        _isAuthenticated = true;
        
        // Save user to local database
        await _databaseService.saveUser(_currentUser!);
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await _authService.register(userData);
      if (result['success']) {
        _currentUser = User.fromJson(result['user']);
        _isAuthenticated = true;
        
        // Save user to local database
        await _databaseService.saveUser(_currentUser!);
        
        notifyListeners();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _setError(null);
      
      // Clear local database
      await _databaseService.clearUserData();
      
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final userData = await _authService.getCurrentUser();
        if (userData != null) {
          _currentUser = User.fromJson(userData);
          _isAuthenticated = true;
        }
      }
      
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _setError('Auth check failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> refreshToken() async {
    try {
      final result = await _authService.refreshToken();
      return result;
    } catch (e) {
      _setError('Token refresh failed: ${e.toString()}');
      return false;
    }
  }
  
  void clearError() {
    _setError(null);
  }
}