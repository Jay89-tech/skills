// lib/views/skills/skills_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/skill_controller.dart';
import '../../models/skill_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import '../common/widgets/loading_widget.dart';
import '../common/widgets/error_widget.dart' as custom;
import '../common/widgets/custom_button.dart';
import 'add_skill_screen.dart';
import 'edit_skill_screen.dart';

class SkillsScreen extends StatefulWidget {
  @override
  _SkillsScreenState createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final SkillController _skillController = SkillController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSkills();
    });
  }

  Future<void> _loadSkills() async {
    final profileController = Provider.of<ProfileController>(context, listen: false);
    await profileController.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Skills'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddSkill(),
          ),
        ],
      ),
      body: Consumer<ProfileController>(
        builder: (context, profileController, _) {
          if (profileController.isLoading) {
            return const LoadingWidget(message: 'Loading your skills...');
          }

          if (profileController.errorMessage != null) {
            return custom.ErrorWidget(
              message: profileController.errorMessage!,
              onRetry: _loadSkills,
            );
          }

          return Column(
            children: [
              _buildSearchAndFilter(),
              Expanded(
                child: _buildSkillsList(profileController.userSkills),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddSkill,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search skills...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All'),
                ...SkillCategory.values.map((category) => 
                  _buildCategoryChip(Helpers.getSkillCategoryName(category))
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSkillsList(List<Skill> skills) {
    final filteredSkills = _filterSkills(skills);

    if (filteredSkills.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredSkills.length,
      itemBuilder: (context, index) {
        return _buildSkillCard(filteredSkills[index]);
      },
    );
  }

  List<Skill> _filterSkills(List<Skill> skills) {
    List<Skill> filtered = skills;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((skill) {
        final categoryName = Helpers.getSkillCategoryName(skill.category);
        return categoryName == _selectedCategory;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((skill) {
        return skill.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (skill.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    return filtered;
  }

  Widget _buildSkillCard(Skill skill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToEditSkill(skill),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      skill.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleSkillAction(value, skill),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      Helpers.getSkillCategoryName(skill.category),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Helpers.getProficiencyLevelColor(skill.proficiency).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Helpers.getProficiencyLevelIcon(skill.proficiency),
                          size: 14,
                          color: Helpers.getProficiencyLevelColor(skill.proficiency),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Helpers.getProficiencyLevelName(skill.proficiency),
                          style: TextStyle(
                            fontSize: 12,
                            color: Helpers.getProficiencyLevelColor(skill.proficiency),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (skill.description != null && skill.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  skill.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Last updated: ${Helpers.formatRelativeTime(skill.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All'
                ? 'No skills match your filters'
                : 'No skills added yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All'
                ? 'Try adjusting your search or filters'
                : 'Start building your skills portfolio',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Add Your First Skill',
            onPressed: _navigateToAddSkill,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  void _handleSkillAction(String action, Skill skill) {
    switch (action) {
      case 'edit':
        _navigateToEditSkill(skill);
        break;
      case 'delete':
        _showDeleteConfirmation(skill);
        break;
    }
  }

  void _showDeleteConfirmation(Skill skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skill'),
        content: Text('Are you sure you want to delete "${skill.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteSkill(skill.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSkill(String skillId) async {
    final profileController = Provider.of<ProfileController>(context, listen: false);
    final success = await profileController.deleteSkill(skillId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill deleted successfully')),
      );
    }
  }

  void _navigateToAddSkill() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSkillScreen()),
    );
  }

  void _navigateToEditSkill(Skill skill) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditSkillScreen(skill: skill)),
    );
  }
}