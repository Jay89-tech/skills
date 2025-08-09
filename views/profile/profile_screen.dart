// lib/views/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../common/widgets/loading_widget.dart';
import '../common/widgets/error_widget.dart' as custom_error;
import 'widgets/profile_header.dart';
import 'widgets/personal_info_form.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProfileController _profileController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _profileController = ProfileController();
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final userId = authController.currentUser?.id;

    if (userId != null) {
      await _profileController.loadProfile(userId);
    }
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: 'Personal Info',
            ),
            Tab(
              icon: Icon(Icons.star),
              text: 'Skills',
            ),
          ],
        ),
      ),
      body: !_isInitialized
          ? const LoadingWidget(message: 'Loading profile...')
          : ChangeNotifierProvider.value(
              value: _profileController,
              child: Consumer<ProfileController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return const LoadingWidget(message: 'Loading...');
                  }

                  if (controller.errorMessage != null) {
                    return custom_error.ErrorWidget(
                      message: controller.errorMessage!,
                      onRetry: _loadProfile,
                    );
                  }

                  if (controller.user == null) {
                    return const custom_error.ErrorWidget(
                      message: 'Unable to load profile data',
                    );
                  }

                  return Column(
                    children: [
                      ProfileHeader(
                        user: controller.user!,
                        onUpdatePicture: controller.updateProfilePicture,
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            PersonalInfoForm(
                              user: controller.user!,
                              onUpdate: controller.updateProfile,
                              isLoading: controller.isLoading,
                            ),
                            _buildSkillsTab(controller),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildSkillsTab(ProfileController controller) {
    if (controller.skills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_outline,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'No skills added yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Go to Skills section to add your first skill',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/skills');
                },
                icon: const Icon(Icons.add),
                label: const Text('Go to Skills'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );