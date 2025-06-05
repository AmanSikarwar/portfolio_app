import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/portfolio_data_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/personal_info.dart';

class PersonalInfoForm extends StatefulWidget {
  const PersonalInfoForm({super.key});

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _aboutMeController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _profileImageController;
  late TextEditingController _rolesController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  late TextEditingController _resumeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final provider = Provider.of<PortfolioDataProvider>(context, listen: false);
    final info = provider.personalInfo;

    _nameController = TextEditingController(text: info?.name ?? '');
    _titleController = TextEditingController(text: info?.title ?? '');
    _aboutMeController = TextEditingController(text: info?.aboutMe ?? '');
    _emailController = TextEditingController(text: info?.email ?? '');
    _phoneController = TextEditingController(text: info?.phone ?? '');
    _locationController = TextEditingController(text: info?.location ?? '');
    _profileImageController = TextEditingController(
      text: info?.profileImageUrl ?? '',
    );
    _rolesController = TextEditingController(
      text: info?.roles.join(', ') ?? '',
    );
    _linkedinController = TextEditingController(text: info?.linkedinUrl ?? '');
    _githubController = TextEditingController(text: info?.githubUrl ?? '');
    _resumeController = TextEditingController(text: info?.resumeUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _aboutMeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _profileImageController.dispose();
    _rolesController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  Future<void> _savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final personalInfo = PersonalInfo(
        id:
            Provider.of<PortfolioDataProvider>(
              context,
              listen: false,
            ).personalInfo?.id ??
            '',
        name: _nameController.text.trim(),
        title: _titleController.text.trim(),
        aboutMe: _aboutMeController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        linkedinUrl: _linkedinController.text.trim(),
        githubUrl: _githubController.text.trim(),
        resumeUrl: _resumeController.text.trim(),
        profileImageUrl: _profileImageController.text.trim(),
        roles: _rolesController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        createdAt:
            Provider.of<PortfolioDataProvider>(
              context,
              listen: false,
            ).personalInfo?.createdAt ??
            DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final provider = Provider.of<PortfolioDataProvider>(
        context,
        listen: false,
      );
      await provider.updatePersonalInfo(personalInfo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Personal information updated successfully!'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _titleController,
                      label: 'Professional Title',
                      icon: Icons.work,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your title';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _profileImageController,
                      label: 'Profile Image URL',
                      icon: Icons.image,
                      keyboardType: TextInputType.url,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      icon: Icons.location_on,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionHeader('About'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _aboutMeController,
                label: 'About Me',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your about me section';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _rolesController,
                label: 'Roles (comma-separated)',
                icon: Icons.group,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter at least one role';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              _buildSectionHeader('Social Links'),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _linkedinController,
                label: 'LinkedIn URL',
                icon: Icons.link,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _githubController,
                label: 'GitHub URL',
                icon: Icons.code,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _resumeController,
                label: 'Resume URL',
                icon: Icons.picture_as_pdf,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _savePersonalInfo,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
