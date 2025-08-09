// lib/views/skills/skills_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/skill_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/skill_model.dart';
import '../../utils/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import '../common/widgets/loading_widget.dart';
import '../common/widgets/error_widget.dart' as custom_error;
import '../common/dialogs/confirmation_dialog.dart';
import 'add_skill_screen.dart';
import 'widgets/skill_card.dart';

class SkillsScreen extends StatefulWidget {
  @override
  _SkillsScreenState createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> with SingleTickerProviderStateMixin {
  final SkillController _skillController = SkillController();
  late TabController _tabController;
  
  List<Skill> _skills = [];
  List<Skill> _filteredSkills = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  SkillCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: SkillCategory.values.length + 1, vsync: this);
    _loadSkills();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSkills() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final userId = authController.currentUser?.id;

      if (userId != null) {
        _skills = await _skillController.getUserSkills(userId);
        _filterSkills();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSkills() {
    _filteredSkills = _skills.where((skill) {
      final matchesSearch = _searchQuery.isEmpty ||
          skill.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (skill.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesCategory = _selectedCategory == null || skill.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();

    // Sort by proficiency level and name
    _filteredSkills.sort((a, b) {
      final proficiencyCompare = b.proficiency.index.compareTo(a.proficiency.index);
      if (proficiencyCompare != 0) return proficiencyCompare;
      return a.name.compareTo(b.name);
    });

    setState(() {});
  }

  Future<void> _deleteSkill(Skill skill) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Skill',
      message: 'Are you sure you want to delete "${skill.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      icon: Icons.delete,
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        await _skillController.deleteSkill(skill.id);
        _skills.removeWhere((s) => s.id == skill.id);
        _filterSkills();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Skill deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete skill: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToAddSkill([Skill? skillToEdit]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSkillScreen(skillToEdit: skillToEdit),
      ),
    );

    if (result == true) {
      _loadSkills();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Skills'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          onTap: (index) {
            setState(() {
              _selectedCategory = index == 0 ? null : SkillCategory.values[index - 1];
            });
            _filterSkills();
          },
          tabs: [
            const Tab(text: 'All'),
            ...SkillCategory.values.map((category) => 
              Tab(text: Helpers.getSkillCategoryName(category))
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddSkill(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _filterSkills();
        },
        decoration: InputDecoration(
          hintText: 'Search skills...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                    _filterSkills();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading skills...');
    }

    if (_errorMessage != null) {
      return custom_error.ErrorWidget(
        message: _errorMessage!,
        onRetry: _loadSkills,
      );
    }

    if (_filteredSkills.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadSkills,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredSkills.length,
        itemBuilder: (context, index) {
          final skill = _filteredSkills[index];
          return SkillCard(
            skill: skill,
            onEdit: () => _navigateToAddSkill(skill),
            onDelete: () => _deleteSkill(skill),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchQuery.isNotEmpty;
    final hasFilter = _selectedCategory != null;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch || hasFilter ? Icons.search_off : Icons.star_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              hasSearch || hasFilter 
                  ? 'No skills found'
                  : 'No skills yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch || hasFilter
                  ? 'Try adjusting your search or filter criteria'
                  : 'Add your first skill to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasSearch && !hasFilter) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _navigateToAddSkill(),
                icon: const Icon(Icons.add),
                label: const Text('Add Skill'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}