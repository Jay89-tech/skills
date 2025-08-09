// lib/views/dashboard/widgets/activity_list.dart
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/helpers.dart';

class ActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const ActivityList({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: activities.isEmpty
              ? _buildEmptyState(context)
              : _buildActivityList(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No recent activities',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your activities will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityItem(context, activity);
      },
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    final title = activity['title'] ?? 'Unknown Activity';
    final description = activity['description'] ?? '';
    final timestamp = activity['timestamp'] != null
        ? DateTime.parse(activity['timestamp'])
        : DateTime.now();
    final type = activity['type'] ?? 'general';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getActivityColor(type).withOpacity(0.2),
        child: Icon(
          _getActivityIcon(type),
          color: _getActivityColor(type),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 2),
          Text(
            Helpers.formatRelativeTime(timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'skill_added':
        return Icons.add_circle_outline;
      case 'skill_updated':
        return Icons.edit_outlined;
      case 'assessment_completed':
        return Icons.check_circle_outline;
      case 'profile_updated':
        return Icons.person_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'skill_added':
        return Colors.green;
      case 'skill_updated':
        return Colors.blue;
      case 'assessment_completed':
        return Colors.purple;
      case 'profile_updated':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }
}