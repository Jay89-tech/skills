// lib/controllers/notification_controller.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
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
  
  Future<bool> loadNotifications() async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.get('/notifications');
      _notifications = (response.data['notifications'] as List)
          .map((notifData) => NotificationModel.fromJson(notifData))
          .toList();
      
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to load notifications: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _apiService.put('/notifications/$notificationId/read');
      
      // Update local notification
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Failed to mark notification as read: ${e.toString()}');
      return false;
    }
  }
  
  Future<bool> markAllAsRead() async {
    try {
      await _apiService.put('/notifications/read-all');
      
      // Update all local notifications
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to mark all notifications as read: ${e.toString()}');
      return false;
    }
  }
  
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _apiService.delete('/notifications/$notificationId');
      
      // Remove from local list
      _notifications.removeWhere((n) => n.id == notificationId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete notification: ${e.toString()}');
      return false;
    }
  }
  
  Future<void> requestPermissions() async {
    await _notificationService.requestPermissions();
  }
  
  void clearError() {
    _setError(null);
  }
}