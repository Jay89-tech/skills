import 'package:flutter/material.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import 'widgets/stat_card.dart';
import 'widgets/action_card.dart';
import 'widgets/activity_list.dart';
import 'widgets/burger_menu.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _dashboardController = DashboardController();
  final UserController _userController = UserController();
  
  User? _currentUser;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = await _userController.getCurrentUser();
      _dashboardData = await _dashboardController.getDashboardData(_currentUser!.id);
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Skills Audit Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: BurgerMenu(user: _currentUser!),
      body: _buildDashboardBody(),
    );
  }

  Widget _buildDashboardBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          SizedBox(height: 20),
          _buildStatsSection(),
          SizedBox(height: 24),
          ActivityList(activities: _dashboardData!['recent_activities']),
          SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${_currentUser!.name}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ready to update your skills today?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Skills Registered',
            value: _dashboardData!['skills_count'].toString(),
            icon: Icons.star,
            color: Colors.amber,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Assessments',
            value: _dashboardData!['assessments_count'].toString(),
            icon: Icons.assignment,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                title: 'Add New Skill',
                icon: Icons.add_circle,
                onTap: () => _dashboardController.navigateToAddSkill(context),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ActionCard(
                title: 'Update Profile',
                icon: Icons.edit,
                onTap: () => _dashboardController.navigateToProfile(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}