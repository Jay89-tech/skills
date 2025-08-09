// lib/views/skills/add_skill_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/skill_controller.dart';
import '../../models/skill_model.dart';
import '../../utils/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import '../../services/validation_service.dart';
import '../common/widgets/custom_text_field.dart';
import '../common/widgets/custom_button.dart';

class AddSkillScreen extends StatefulWidget {
  @override
  _AddSkillScreenState createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillController = SkillController();
  final _validationService = ValidationService();

  SkillCategory _selectedCategory = SkillCategory.technology;
  ProficiencyLevel _selectedProficiency = ProficiencyLevel.beginner;
  List<String> _certifications = [];
  final _certificationController = TextEditingController();
  List<String> _suggestions = [];
  bool _isLoadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  void _onNameChanged() async {
    final query = _nameController.text.trim();
    if (query.length >= 2) {
      setState(() {
        _isLoadingSuggestions = true;
      });
      
      final suggestions = await _skillController.getSkillSuggestions(query);
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } else {
      setState(() {
        _suggestions.clear();
        _isLoadingSuggestions = false;
      });
    }
  }

  Future<void> _addSkill() async {
    if (!_formKey.currentState!.validate()) return;

    final profileController = Provider.of<ProfileController>(context, listen: false);
    final user = profileController.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
      return;
    }

    final skill = Skill(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      name: _nameController.text.trim(),
      category: _selectedCategory,
      proficiency: _selectedProficiency,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      certifications: _certifications.isEmpty ? null : _certifications,
      lastAssessed: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await profileController.addSkill(skill);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill added successfully!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileController.errorMessage ?? 'Failed to add skill'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Skill'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProfileController>(
        builder: (context, profileController, _) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkillNameField(),
                  const SizedBox(height: 16),
                  _buildCategoryField(),
                  const SizedBox(height: 16),
                  _buildProficiencyField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  _buildCertificationsField(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Add Skill',
                      onPressed: _addSkill,
                      isLoading: profileController.isLoading,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkillNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _nameController,
          labelText: 'Skill Name *',
          prefixIcon: Icons.star_outline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Skill name is required';
            }
            if (!_validationService.isValidSkillName(value)) {
              return 'Please enter a valid skill name';
            }
            return null;
          },
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(suggestion),
                  onTap: () {
                    _nameController.text = suggestion;
                    setState(() {
                      _suggestions.clear();
                    });
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<SkillCategory>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.category_outlined),
            border: OutlineInputBorder(),
          ),
          items: SkillCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(Helpers.getSkillCategoryName(category)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildProficiencyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proficiency Level *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...ProficiencyLevel.values.map((level) {
          return RadioListTile<ProficiencyLevel>(
            title: Row(
              children: [
                Icon(
                  Helpers.getProficiencyLevelIcon(level),
                  color: Helpers.getProficiencyLevelColor(level),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(Helpers.getProficiencyLevelName(level)),
              ],
            ),
            subtitle: Text(
              _skillController.getProficiencyDescription(level),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: level,
            groupValue: _selectedProficiency,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedProficiency = value;
                });
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return CustomTextField(
      controller: _descriptionController,
      labelText: 'Description (Optional)',
      prefixIcon: Icons.description_outlined,
      maxLines: 3,
      validator: (value) {
        if (value != null && !_validationService.isValidDescription(value)) {
          return 'Description must be less than 500 characters';
        }
        return null;
      },
    );
  }

  Widget _buildCertificationsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certifications (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _certificationController,
                decoration: const InputDecoration(
                  hintText: 'Add certification',
                  prefixIcon: Icon(Icons.workspace_premium_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final cert = _certificationController.text.trim();
                if (cert.isNotEmpty && !_certifications.contains(cert)) {
                  setState(() {
                    _certifications.add(cert);
                    _certificationController.clear();
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        if (_certifications.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _certifications.map((cert) {
              return Chip(
                label: Text(cert),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _certifications.remove(cert);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}