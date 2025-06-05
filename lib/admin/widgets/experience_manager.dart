import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/portfolio_data_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/experience.dart';

class ExperienceManager extends StatefulWidget {
  const ExperienceManager({super.key});

  @override
  State<ExperienceManager> createState() => _ExperienceManagerState();
}

class _ExperienceManagerState extends State<ExperienceManager> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _skillsController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _durationController = TextEditingController();

  bool _isLoading = false;
  bool _isCurrent = false;
  Experience? _editingExperience;

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _skillsController.dispose();
    _responsibilitiesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _companyController.clear();
    _roleController.clear();
    _descriptionController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _skillsController.clear();
    _responsibilitiesController.clear();
    _durationController.clear();
    setState(() {
      _isCurrent = false;
      _editingExperience = null;
    });
  }

  void _editExperience(Experience experience) {
    setState(() {
      _editingExperience = experience;
      _companyController.text = experience.company;
      _roleController.text = experience.role;
      _descriptionController.text = experience.description;
      _startDateController.text = experience.startDate;
      _endDateController.text = experience.endDate ?? '';
      _durationController.text = experience.duration;
      _skillsController.text = experience.skills.join(', ');
      _responsibilitiesController.text = experience.responsibilities.join(', ');
      _isCurrent = experience.endDate == null;
    });
  }

  Future<void> _saveExperience() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final experience = Experience(
        id: _editingExperience?.id ?? '',
        company: _companyController.text.trim(),
        role: _roleController.text.trim(),
        duration: _durationController.text.trim(),
        startDate: _startDateController.text.trim(),
        endDate: _isCurrent ? null : _endDateController.text.trim(),
        description: _descriptionController.text.trim(),
        responsibilities: _responsibilitiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        skills: _skillsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        iconColor: _editingExperience?.iconColor,
        sortOrder: _editingExperience?.sortOrder ?? 0,
        isActive: true,
        createdAt: _editingExperience?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final provider = Provider.of<PortfolioDataProvider>(
        context,
        listen: false,
      );

      if (_editingExperience != null) {
        await provider.updateExperience(experience);
      } else {
        await provider.addExperience(experience);
      }

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingExperience != null
                  ? 'Experience updated successfully!'
                  : 'Experience added successfully!',
            ),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save experience: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteExperience(Experience experience) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colorScheme.surfaceContainerHigh,
        title: const Text('Delete Experience'),
        content: Text(
          'Are you sure you want to delete "${experience.role}" at "${experience.company}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final provider = Provider.of<PortfolioDataProvider>(
          context,
          listen: false,
        );
        await provider.deleteExperience(experience.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Experience deleted successfully!'),
              backgroundColor: AppTheme.accentColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete experience: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Section
          Expanded(
            flex: 2,
            child: Card(
              color: AppTheme.colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.work, color: AppTheme.accentColor),
                            const SizedBox(width: 12),
                            Text(
                              _editingExperience != null
                                  ? 'Edit Experience'
                                  : 'Add New Experience',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: AppTheme.accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildTextField(
                          controller: _companyController,
                          label: 'Company',
                          icon: Icons.business,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the company name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _roleController,
                          label: 'Role/Position',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the role';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.description,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _startDateController,
                                label: 'Start Date',
                                icon: Icons.calendar_today,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter start date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _endDateController,
                                label: 'End Date',
                                icon: Icons.calendar_today,
                                enabled: !_isCurrent,
                                validator: (value) {
                                  if (!_isCurrent &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Please enter end date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        CheckboxListTile(
                          title: const Text('Current Position'),
                          value: _isCurrent,
                          onChanged: (value) {
                            setState(() {
                              _isCurrent = value ?? false;
                              if (_isCurrent) {
                                _endDateController.clear();
                              }
                            });
                          },
                          activeColor: AppTheme.accentColor,
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _durationController,
                          label: 'Duration (e.g., "2 years 3 months")',
                          icon: Icons.schedule,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the duration';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _responsibilitiesController,
                          label: 'Responsibilities (comma separated)',
                          icon: Icons.task_alt,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter key responsibilities';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _skillsController,
                          label: 'Skills/Technologies (comma separated)',
                          icon: Icons.code,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter skills/technologies used';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _saveExperience,
                                icon: _isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.black,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        _editingExperience != null
                                            ? Icons.update
                                            : Icons.add,
                                      ),
                                label: Text(
                                  _isLoading
                                      ? 'Saving...'
                                      : _editingExperience != null
                                      ? 'Update Experience'
                                      : 'Add Experience',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentColor,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            if (_editingExperience != null) ...[
                              const SizedBox(width: 16),
                              TextButton(
                                onPressed: _clearForm,
                                child: const Text('Cancel'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Experiences List Section
          Expanded(
            flex: 3,
            child: Card(
              color: AppTheme.colorScheme.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list, color: AppTheme.accentColor),
                        const SizedBox(width: 12),
                        Text(
                          'Current Experiences',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Expanded(
                      child: Consumer<PortfolioDataProvider>(
                        builder: (context, provider, child) {
                          if (provider.experiences.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.work_outline,
                                    size: 64,
                                    color: Colors.white.withAlpha(100),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No experiences added yet',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(150),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: provider.experiences.length,
                            itemBuilder: (context, index) {
                              final experience = provider.experiences[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: AppTheme
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.accentColor
                                        .withAlpha(50),
                                    child: Icon(
                                      Icons.work,
                                      color: AppTheme.accentColor,
                                    ),
                                  ),
                                  title: Text(
                                    experience.role,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        experience.company,
                                        style: TextStyle(
                                          color: AppTheme.accentColor,
                                        ),
                                      ),
                                      Text(
                                        '${experience.startDate} - ${experience.endDate ?? 'Present'}',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(150),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _editExperience(experience),
                                        icon: const Icon(Icons.edit),
                                        color: AppTheme.accentColor,
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _deleteExperience(experience),
                                        icon: const Icon(Icons.delete),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppTheme.accentColor),
        filled: true,
        fillColor: enabled
            ? AppTheme.colorScheme.surfaceContainerHighest.withAlpha(100)
            : Colors.grey.withAlpha(50),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(50)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withAlpha(50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withAlpha(50)),
        ),
      ),
    );
  }
}
