// lib/views/skills/add_skill_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/skill_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/skill_model.dart';
import '../../utils/enums.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import '../../services/validation_service.dart';
import '../common/widgets/custom_text_field.dart';
import '../common/widgets/custom_button.dart';
import '../common/widgets/loading_widget.dart';

class AddSkillScreen extends StatefulWidget {
  final Skill? skillToEdit;

  const AddSkillScreen({
    Key? key,
    this.skillToEdit,
  }) : super(key: key);

  @override
  _AddSkillScreenState createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skillController = SkillController();
  final _validationService = ValidationService();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _certificationsController = TextEditingController();
  
  SkillCategory _selectedCategory = SkillCategory.software;
  ProficiencyLevel _selectedProficiency = ProficiencyLevel.beginner;
  
  bool _isLoading = false;
  List<String> _skillSuggestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.skillToEdit != null) {
      _populateFields(widget.skillToEdit!);
    }
  }

  void _populateFields(Skill skill) {
    _nameController.text = skill.name;
    _descriptionController.text = skill.description ?? '';
    _certificationsController.text = skill.certifications?.join(', ') ?? '';
    _selectedCategory = skill.category;
    _selectedProficiency = skill.proficiency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  Future<void> _searchSkillSuggestions(String query) async {
    if (query.length > 2) {
      final suggestions = await _skillController.getSkillSuggestions(query);
      setState(() {
        _skillSuggestions = suggestions;
      });
    } else {
      setState(() {
        _skillSuggestions = [];
      });
    }
  }

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final userId = authController.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final skill = Skill(
        id: widget.skillToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        proficiency: _selectedProficiency,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        certifications: _certificationsController.text.trim().isEmpty
            ? null
            : _certificationsController.text.split(',')
                .map((cert) => cert.trim())
                .where((cert) => cert.isNotEmpty)
                .toList(),
        lastAssessed: widget.skillToEdit?.lastAssessed,
        createdAt: widget.skillToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.skillToEdit != null) {
        await _skillController.updateSkill(skill);
      } else {
        await _skillController.createSkill(skill);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.skillToEdit != null
                  ? 'Skill updated successfully'
                  : 'Skill added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skillToEdit != null ? 'Edit Skill' : 'Add New Skill'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Saving skill...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 24),
                    _buildProficiencyInfo(),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: widget.skillToEdit != null ? 'Update Skill' : 'Add Skill',
                      onPressed: _saveSkill,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSkillNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start