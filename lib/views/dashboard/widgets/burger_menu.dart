// lib/views/dashboard/widgets/burger_menu.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/helpers.dart';
import '../../../utils/routes.dart';

class BurgerMenu extends StatelessWidget {
  final User user;

  const BurgerMenu({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildUserHeader(context),
          Expanded(
            child: _buildMenuItems(context),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: user.profilePicture != null
            ? FileImage(File(user.profilePicture!))
            : null,
        child: user.profilePicture == null
            ? Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )
            : null,
      ),
      accountName: Text(
        user.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          Text(
            '${user.position ?? 'Employee'} • ${user.department}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildMenuItem(
          context,
          icon: Icons.dashboard_outlined,
          title: 'Dashboard',
          onTap: () => _navigateTo(context, Routes.dashboard),
        ),
        _buildMenuItem(
          context,
          icon: Icons.person_outlined,
          title: 'My Profile',
          onTap: () => _navigateTo(context, '/profile'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.star_outlined,
          title: 'My Skills',
          onTap: () => _navigateTo(context, '/skills'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.assignment_outlined,
          title: 'Assessments',
          onTap: () => _navigateTo(context, '/assessments'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () => _navigateTo(context, '/notifications'),
        ),
        const Divider(),
        if (user.role == UserRole.admin || user.role == UserRole.superAdmin) ...[
          _buildMenuItem(
            context,
            icon: Icons.admin_panel_settings_outlined,
            title: 'Admin Panel',
            onTap: () => _navigateTo(context, '/admin'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.people_outlined,
            title: 'User Management',
            onTap: () => _navigateTo(context, '/admin/users'),
          ),
          _buildMenuItem(
            context,
            icon: Icons.bar_chart_outlined,
            title: 'Reports',
            onTap: () => _navigateTo(context, '/admin/reports'),
          ),
          const Divider(),
        ],
        _buildMenuItem(
          context,
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () => _navigateTo(context, '/settings'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () => _showHelpDialog(context),
        ),
        _buildMenuItem(
          context,
          icon: Icons.info_outline,
          title: 'About',
          onTap: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Skills Audit v1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authController = Provider.of<AuthController>(context, listen: false);
              await authController.logout();
              Navigator.pushReplacementNamed(context, Routes.auth);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('National Treasury Skills Audit System'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('Build: 2024.1'),
            SizedBox(height: 16),
            Text('Developed by National Treasury IT Department'),
            Text('© 2024 National Treasury, South Africa'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}AxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help with the Skills Audit app?'),
            SizedBox(height: 16),
            Text('📧 Email: support@treasury.gov.za'),
            Text('📞 Phone: +27 12 315 5009'),
            Text('🌐 Web: www.treasury.gov.za/skills-support'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Skills Audit'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('National Treasury Skills Audit System'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            Text('Build: 2024.1'),
            SizedBox(height: 16),
            Text('Developed by National Treasury IT Department'),
            Text('© 2024 National Treasury, South Africa'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }