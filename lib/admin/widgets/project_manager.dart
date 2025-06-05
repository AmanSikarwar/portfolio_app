import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/portfolio_data_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/project.dart';

class ProjectManager extends StatefulWidget {
  const ProjectManager({super.key});

  @override
  State<ProjectManager> createState() => _ProjectManagerState();
}

class _ProjectManagerState extends State<ProjectManager> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _longDescriptionController = TextEditingController();
  final _githubUrlController = TextEditingController();
  final _liveUrlController = TextEditingController();
  final _technologiesController = TextEditingController();
  final _featuresController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _screenshotsController = TextEditingController();
  final _starsController = TextEditingController();
  final _commitCountController = TextEditingController();
  final _statusController = TextEditingController();

  bool _isLoading = false;
  bool _isFeatured = false;
  Project? _editingProject;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _longDescriptionController.dispose();
    _githubUrlController.dispose();
    _liveUrlController.dispose();
    _technologiesController.dispose();
    _featuresController.dispose();
    _imageUrlController.dispose();
    _screenshotsController.dispose();
    _starsController.dispose();
    _commitCountController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _longDescriptionController.clear();
    _githubUrlController.clear();
    _liveUrlController.clear();
    _technologiesController.clear();
    _featuresController.clear();
    _imageUrlController.clear();
    _screenshotsController.clear();
    _starsController.clear();
    _commitCountController.clear();
    _statusController.clear();
    setState(() {
      _isFeatured = false;
      _editingProject = null;
    });
  }

  void _editProject(Project project) {
    setState(() {
      _editingProject = project;
      _titleController.text = project.title;
      _descriptionController.text = project.description;
      _longDescriptionController.text = project.longDescription ?? '';
      _githubUrlController.text = project.githubUrl;
      _liveUrlController.text = project.liveUrl ?? '';
      _technologiesController.text = project.technologies.join(', ');
      _featuresController.text = project.features.join(', ');
      _imageUrlController.text = project.imageUrl ?? '';
      _screenshotsController.text = project.screenshots.join(', ');
      _starsController.text = project.stars.toString();
      _commitCountController.text = project.commitCount?.toString() ?? '';
      _statusController.text = project.status;
      _isFeatured = project.isFeatured;
    });
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final project = Project(
        id: _editingProject?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        longDescription: _longDescriptionController.text.trim().isEmpty
            ? null
            : _longDescriptionController.text.trim(),
        githubUrl: _githubUrlController.text.trim(),
        liveUrl: _liveUrlController.text.trim().isEmpty
            ? null
            : _liveUrlController.text.trim(),
        technologies: _technologiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        features: _featuresController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        screenshots: _screenshotsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        stars: int.tryParse(_starsController.text.trim()) ?? 0,
        commitCount: _commitCountController.text.trim().isEmpty
            ? null
            : int.tryParse(_commitCountController.text.trim()),
        status: _statusController.text.trim().isEmpty
            ? 'planned'
            : _statusController.text.trim(),
        sortOrder: _editingProject?.sortOrder ?? 0,
        isActive: true,
        isFeatured: _isFeatured,
        createdAt: _editingProject?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final provider = Provider.of<PortfolioDataProvider>(
        context,
        listen: false,
      );

      if (_editingProject != null) {
        await provider.updateProject(project);
      } else {
        await provider.addProject(project);
      }

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingProject != null
                  ? 'Project updated successfully!'
                  : 'Project added successfully!',
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
            content: Text('Failed to save project: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProject(Project project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colorScheme.surfaceContainerHigh,
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.title}"?'),
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
        await provider.deleteProject(project.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Project deleted successfully!'),
              backgroundColor: AppTheme.accentColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete project: $e'),
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
                            Icon(Icons.code, color: AppTheme.accentColor),
                            const SizedBox(width: 12),
                            Text(
                              _editingProject != null
                                  ? 'Edit Project'
                                  : 'Add New Project',
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
                          controller: _titleController,
                          label: 'Project Title',
                          icon: Icons.title,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the project title';
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

                        _buildTextField(
                          controller: _githubUrlController,
                          label: 'GitHub URL',
                          icon: Icons.code,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the GitHub URL';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _liveUrlController,
                          label: 'Live URL (optional)',
                          icon: Icons.link,
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _technologiesController,
                          label: 'Technologies (comma separated)',
                          icon: Icons.settings,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter technologies used';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _featuresController,
                          label: 'Features (comma separated)',
                          icon: Icons.star,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter project features';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        CheckboxListTile(
                          title: const Text('Featured Project'),
                          subtitle: const Text(
                            'Display in featured projects section',
                          ),
                          value: _isFeatured,
                          onChanged: (value) {
                            setState(() {
                              _isFeatured = value ?? false;
                            });
                          },
                          activeColor: AppTheme.accentColor,
                        ),

                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _saveProject,
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
                                        _editingProject != null
                                            ? Icons.update
                                            : Icons.add,
                                      ),
                                label: Text(
                                  _isLoading
                                      ? 'Saving...'
                                      : _editingProject != null
                                      ? 'Update Project'
                                      : 'Add Project',
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
                            if (_editingProject != null) ...[
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

          // Projects List Section
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
                          'Current Projects',
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
                          if (provider.projects.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.code_outlined,
                                    size: 64,
                                    color: Colors.white.withAlpha(100),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No projects added yet',
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
                            itemCount: provider.projects.length,
                            itemBuilder: (context, index) {
                              final project = provider.projects[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: AppTheme
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: project.isFeatured
                                        ? AppTheme.accentColor.withAlpha(100)
                                        : Colors.grey.withAlpha(100),
                                    child: Icon(
                                      project.isFeatured
                                          ? Icons.star
                                          : Icons.code,
                                      color: project.isFeatured
                                          ? AppTheme.accentColor
                                          : Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    project.title,
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
                                        project.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(150),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        children: project.technologies
                                            .take(3)
                                            .map((tech) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentColor
                                                      .withAlpha(50),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  tech,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: AppTheme.accentColor,
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => _editProject(project),
                                        icon: const Icon(Icons.edit),
                                        color: AppTheme.accentColor,
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _deleteProject(project),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppTheme.accentColor),
        filled: true,
        fillColor: AppTheme.colorScheme.surfaceContainerHighest.withAlpha(100),
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
      ),
    );
  }
}
