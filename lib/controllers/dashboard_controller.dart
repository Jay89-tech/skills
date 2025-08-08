import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardController {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getDashboardData(String userId) async {
    try {
      final response = await _apiService.get('/dashboard/$userId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentActivities(String userId) async {
    try {
      final response = await _apiService.get('/activities/$userId?limit=5');
      return List<Map<String, dynamic>>.from(response.data['activities']);
    } catch (e) {
      throw Exception('Failed to load recent activities: $e');
    }
  }

  void navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  void navigateToAddSkill(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSkillScreen()),
    );
  }

  Future<void> refreshDashboard(String userId) async {
    // Refresh dashboard data
    await getDashboardData(userId);
  }
}