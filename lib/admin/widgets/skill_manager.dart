import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/portfolio_data_provider.dart';
import '../../data/models/skill.dart';
import '../../widgets/common/state_widgets.dart' as state_widgets;

class SkillManager extends StatefulWidget {
  const SkillManager({super.key});

  @override
  State<SkillManager> createState() => _SkillManagerState();
}

class _SkillManagerState extends State<SkillManager> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  final _categoryController = TextEditingController();

  Skill? _editingSkill;
  String _selectedCategory = 'Technical';
  double _skillLevel = 5.0;

  // Categories will be populated dynamically from existing skills
  Set<String> get _availableCategories {
    final provider = context.read<PortfolioDataProvider>();
    final existingCategories = provider.skills.map((s) => s.category).toSet();

    // Always include default categories
    final defaultCategories = {
      'Technical',
      'Programming Languages',
      'Frameworks',
      'Tools',
      'Soft Skills',
      'Design',
      'Other',
    };

    // Combine existing and default categories
    return {...defaultCategories, ...existingCategories};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _levelController.clear();
    _categoryController.clear();
    _editingSkill = null;
    _selectedCategory = 'Technical';
    _skillLevel = 5.0;
    setState(() {});
  }

  void _editSkill(Skill skill) {
    setState(() {
      _editingSkill = skill;
      _nameController.text = skill.name;
      _selectedCategory = skill.category;
      _skillLevel = skill.proficiency.toDouble();
    });
  }

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PortfolioDataProvider>();

    try {
      if (_editingSkill != null) {
        // Update existing skill
        final updatedSkill = Skill(
          id: _editingSkill!.id,
          name: _nameController.text.trim(),
          proficiency: _skillLevel.round(),
          category: _selectedCategory,
          iconName: _editingSkill!.iconName,
          color: _editingSkill!.color,
          sortOrder: _editingSkill!.sortOrder,
          isActive: _editingSkill!.isActive,
          createdAt: _editingSkill!.createdAt,
          updatedAt: DateTime.now(),
        );
        await provider.updateSkill(updatedSkill);
      } else {
        // Add new skill
        final skill = Skill(
          id: '',
          name: _nameController.text.trim(),
          proficiency: _skillLevel.round(),
          category: _selectedCategory,
          iconName: null,
          color: null,
          sortOrder: 0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await provider.addSkill(skill);
      }

      _resetForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingSkill != null
                  ? 'Skill updated successfully!'
                  : 'Skill added successfully!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteSkill(String skillId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skill'),
        content: const Text(
          'Are you sure you want to delete this skill? This action cannot be undone.',
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

    if (confirmed != true) return;

    try {
      final messenger = ScaffoldMessenger.of(
        context, // ignore: use_build_context_synchronously
      );
      final provider =
          context // ignore: use_build_context_synchronously
              .read<PortfolioDataProvider>();
      await provider.deleteSkill(
        skillId,
      ); // ignore: use_build_context_synchronously

      if (mounted) {
        // ignore: use_build_context_synchronously
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Skill deleted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting skill: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioDataProvider>(
      builder: (context, provider, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Panel
            Expanded(
              flex: 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _editingSkill != null
                                  ? 'Edit Skill'
                                  : 'Add New Skill',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const Spacer(),
                            if (_editingSkill != null)
                              TextButton(
                                onPressed: _resetForm,
                                child: const Text('Cancel Edit'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Skill Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Skill Name',
                            hintText: 'e.g., Flutter, Python, Communication',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a skill name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown
                        Consumer<PortfolioDataProvider>(
                          builder: (context, provider, child) {
                            final categories = _availableCategories.toList()
                              ..sort();

                            // Ensure selected category exists in available categories
                            if (!categories.contains(_selectedCategory)) {
                              _selectedCategory = categories.first;
                            }

                            return DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Skill Level Slider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Skill Level: ${_skillLevel.round()}/10',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _skillLevel,
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: _skillLevel.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  _skillLevel = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Beginner',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text('Expert', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveSkill,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              _editingSkill != null
                                  ? 'Update Skill'
                                  : 'Add Skill',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Skills List Panel
            Expanded(
              flex: 3,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Skills List',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Spacer(),
                          Text(
                            '${provider.skills.length} skills',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      Expanded(
                        child: provider.isLoading
                            ? const state_widgets.LoadingState(
                                message: 'Loading skills...',
                              )
                            : provider.skills.isEmpty
                            ? const state_widgets.EmptyState(
                                icon: Icons.code,
                                title: 'No Skills',
                                description:
                                    'Add your first skill using the form on the left',
                              )
                            : _buildSkillsList(provider.skills),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkillsList(List<Skill> skills) {
    // Group skills by category
    final groupedSkills = <String, List<Skill>>{};
    for (final skill in skills) {
      groupedSkills.putIfAbsent(skill.category, () => []).add(skill);
    }

    return ListView.builder(
      itemCount: groupedSkills.length,
      itemBuilder: (context, index) {
        final category = groupedSkills.keys.elementAt(index);
        final categorySkills = groupedSkills[category]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              category,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${categorySkills.length} skills'),
            initiallyExpanded: true,
            children: categorySkills
                .map((skill) => _buildSkillTile(skill))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildSkillTile(Skill skill) {
    return ListTile(
      title: Text(skill.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Level: ${skill.proficiency}/10'),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: skill.proficiency / 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    skill.proficiency >= 8
                        ? Colors.green
                        : skill.proficiency >= 6
                        ? Colors.orange
                        : skill.proficiency >= 4
                        ? Colors.blue
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _editSkill(skill),
            tooltip: 'Edit skill',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteSkill(skill.id),
            tooltip: 'Delete skill',
          ),
        ],
      ),
    );
  }
}
