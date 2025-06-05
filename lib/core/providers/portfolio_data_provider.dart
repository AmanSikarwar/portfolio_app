import 'package:flutter/foundation.dart';
import 'package:portfolio_app/data/models/personal_info.dart';
import 'package:portfolio_app/data/models/experience.dart';
import 'package:portfolio_app/data/models/skill.dart';
import 'package:portfolio_app/data/models/project.dart';
import 'package:portfolio_app/data/services/supabase_service.dart';
import 'package:portfolio_app/core/services/error_handler.dart';
import 'package:portfolio_app/core/services/logging_service.dart';

enum LoadingState { idle, loading, loaded, error }

class PortfolioDataProvider extends ChangeNotifier {
  // State management
  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;

  // Data
  PersonalInfo? _personalInfo;
  List<Experience> _experiences = [];
  List<Skill> _skills = [];
  Map<String, List<Skill>> _skillsByCategory = {};
  List<Project> _projects = [];
  List<Project> _featuredProjects = [];

  // Getters
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  PersonalInfo? get personalInfo => _personalInfo;
  List<Experience> get experiences => _experiences;
  List<Skill> get skills => _skills;
  Map<String, List<Skill>> get skillsByCategory => _skillsByCategory;
  List<Project> get projects => _projects;
  List<Project> get featuredProjects => _featuredProjects;

  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasError => _loadingState == LoadingState.error;
  bool get isLoaded => _loadingState == LoadingState.loaded;

  // Initialize and load all data
  Future<void> initialize() async {
    if (_loadingState == LoadingState.loading) return;

    _setLoadingState(LoadingState.loading);

    try {
      await Future.wait([
        _loadPersonalInfo(),
        _loadExperiences(),
        _loadSkills(),
        _loadProjects(),
      ]);

      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to load portfolio data: $e');
    }
  }

  // Load individual data sections
  Future<void> _loadPersonalInfo() async {
    try {
      final result = await SupabaseService.getCachedPersonalInfo();
      if (result.isSuccess) {
        _personalInfo = result.data;
        LoggingService.debug('Personal info loaded successfully');
      } else {
        LoggingService.warning(
          'Failed to load personal info: ${result.error?.message}',
        );
        ErrorHandler.handleError(
          result.error!,
          context: 'Loading personal info',
        );
      }
      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading personal info',
        error: e,
        stackTrace: stackTrace,
      );
      ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Loading personal info',
      );
    }
  }

  Future<void> _loadExperiences() async {
    try {
      final result = await SupabaseService.getCachedExperiences();
      if (result.isSuccess) {
        _experiences = result.value;
        LoggingService.debug(
          'Experiences loaded successfully: ${_experiences.length} items',
        );
      } else {
        LoggingService.warning(
          'Failed to load experiences: ${result.error?.message}',
        );
        ErrorHandler.handleError(result.error!, context: 'Loading experiences');
      }
      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading experiences',
        error: e,
        stackTrace: stackTrace,
      );
      ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Loading experiences',
      );
    }
  }

  Future<void> _loadSkills() async {
    try {
      final skillsResult = await SupabaseService.getCachedSkills();
      final categoryResult = await SupabaseService.getSkillsByCategory();

      if (skillsResult.isSuccess) {
        _skills = skillsResult.value;
        LoggingService.debug(
          'Skills loaded successfully: ${_skills.length} items',
        );
      } else {
        LoggingService.warning(
          'Failed to load skills: ${skillsResult.error?.message}',
        );
        ErrorHandler.handleError(
          skillsResult.error!,
          context: 'Loading skills',
        );
      }

      if (categoryResult.isSuccess) {
        _skillsByCategory = categoryResult.value;
        LoggingService.debug(
          'Skills by category loaded successfully: ${_skillsByCategory.length} categories',
        );
      } else {
        LoggingService.warning(
          'Failed to load skills by category: ${categoryResult.error?.message}',
        );
        ErrorHandler.handleError(
          categoryResult.error!,
          context: 'Loading skills by category',
        );
      }

      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading skills',
        error: e,
        stackTrace: stackTrace,
      );
      ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Loading skills',
      );
    }
  }

  Future<void> _loadProjects() async {
    try {
      final projectsResult = await SupabaseService.getCachedProjects();
      final featuredResult = await SupabaseService.getFeaturedProjects();

      if (projectsResult.isSuccess) {
        _projects = projectsResult.value;
        LoggingService.debug(
          'Projects loaded successfully: ${_projects.length} items',
        );
      } else {
        LoggingService.warning(
          'Failed to load projects: ${projectsResult.error?.message}',
        );
        ErrorHandler.handleError(
          projectsResult.error!,
          context: 'Loading projects',
        );
      }

      if (featuredResult.isSuccess) {
        _featuredProjects = featuredResult.value;
        LoggingService.debug(
          'Featured projects loaded successfully: ${_featuredProjects.length} items',
        );
      } else {
        LoggingService.warning(
          'Failed to load featured projects: ${featuredResult.error?.message}',
        );
        ErrorHandler.handleError(
          featuredResult.error!,
          context: 'Loading featured projects',
        );
      }

      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error loading projects',
        error: e,
        stackTrace: stackTrace,
      );
      ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Loading projects',
      );
    }
  }

  // Refresh methods
  Future<void> refreshAll() async {
    SupabaseService.clearCache();
    await initialize();
  }

  Future<void> refreshPersonalInfo() async {
    try {
      final result = await SupabaseService.getPersonalInfo();
      if (result.isSuccess) {
        _personalInfo = result.data;
        LoggingService.info('Personal info refreshed successfully');
      } else {
        LoggingService.warning(
          'Failed to refresh personal info: ${result.error?.message}',
        );
        ErrorHandler.handleError(
          result.error!,
          context: 'Refreshing personal info',
        );
      }
      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error refreshing personal info',
        error: e,
        stackTrace: stackTrace,
      );
      ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Refreshing personal info',
      );
    }
  }

  Future<void> refreshExperiences() async {
    try {
      final result = await SupabaseService.getExperiences();
      if (result.isSuccess) {
        _experiences = result.value;
        LoggingService.info(
          'Experiences refreshed successfully: ${_experiences.length} items',
        );
      } else {
        LoggingService.warning(
          'Failed to refresh experiences: ${result.error?.message}',
        );
        ErrorHandler.handleError(
          result.error!,
          context: 'Refreshing experiences',
        );
      }
      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error refreshing experiences',
        error: e,
        stackTrace: stackTrace,
      );
      ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Refreshing experiences',
      );
    }
  }

  Future<void> refreshSkills() async {
    try {
      final skillsResult = await SupabaseService.getSkills();
      final categoryResult = await SupabaseService.getSkillsByCategory();

      if (skillsResult.isSuccess) {
        _skills = skillsResult.value;
        LoggingService.info(
          'Skills refreshed successfully: ${_skills.length} items',
        );
      } else {
        LoggingService.warning(
          'Failed to refresh skills: ${skillsResult.error?.message}',
        );
        ErrorHandler.handleError(
          skillsResult.error!,
          context: 'Refreshing skills',
        );
      }

      if (categoryResult.isSuccess) {
        _skillsByCategory = categoryResult.value;
        LoggingService.info(
          'Skills by category refreshed successfully: ${_skillsByCategory.length} categories',
        );
      } else {
        LoggingService.warning(
          'Failed to refresh skills by category: ${categoryResult.error?.message}',
        );
        ErrorHandler.handleError(
          categoryResult.error!,
          context: 'Refreshing skills by category',
        );
      }

      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error refreshing skills',
        error: e,
        stackTrace: stackTrace,
      );
      ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Refreshing skills',
      );
    }
  }

  Future<void> refreshProjects() async {
    try {
      final projectsResult = await SupabaseService.getProjects();
      final featuredResult = await SupabaseService.getFeaturedProjects();

      if (projectsResult.isSuccess) {
        _projects = projectsResult.value;
        LoggingService.info(
          'Projects refreshed successfully: ${_projects.length} items',
        );
      } else {
        LoggingService.warning(
          'Failed to refresh projects: ${projectsResult.error?.message}',
        );
        ErrorHandler.handleError(
          projectsResult.error!,
          context: 'Refreshing projects',
        );
      }

      if (featuredResult.isSuccess) {
        _featuredProjects = featuredResult.value;
        LoggingService.info(
          'Featured projects refreshed successfully: ${_featuredProjects.length} items',
        );
      } else {
        LoggingService.warning(
          'Failed to refresh featured projects: ${featuredResult.error?.message}',
        );
        ErrorHandler.handleError(
          featuredResult.error!,
          context: 'Refreshing featured projects',
        );
      }

      notifyListeners();
    } catch (e, stackTrace) {
      LoggingService.error(
        'Error refreshing projects',
        error: e,
        stackTrace: stackTrace,
      );
      ErrorHandler.handleError(
        e,
        stackTrace: stackTrace,
        context: 'Refreshing projects',
      );
    }
  }

  // Utility methods
  List<String> getTechStackIcons() {
    return _skills
        .where((skill) => skill.iconName != null && skill.iconName!.isNotEmpty)
        .map((skill) => skill.iconName!)
        .toList();
  }

  List<String> getRoles() {
    return _personalInfo?.roles ?? ['Developer', 'Designer', 'Problem Solver'];
  }

  String getAboutText() {
    return _personalInfo?.aboutMe ??
        'I am a passionate software developer and data science student at IIT Mandi with a focus on building intuitive and innovative applications. I enjoy exploring new technologies and solving complex problems with clean, efficient code.';
  }

  String getContactEmail() {
    return _personalInfo?.email ?? 'contact@example.com';
  }

  String getResumeUrl() {
    return _personalInfo?.resumeUrl ?? '';
  }

  String getProfileImageUrl() {
    return _personalInfo?.profileImageUrl ?? '';
  }

  // Helper methods
  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    if (state != LoadingState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _loadingState = LoadingState.error;
    _errorMessage = message;
    notifyListeners();
  }

  // Fallback data for when Supabase is not configured
  void loadFallbackData() {
    _personalInfo = PersonalInfo(
      id: 'fallback',
      name: 'Aman Sikarwar',
      title: 'Software Developer & Data Science Student',
      aboutMe:
          'I am a passionate software developer and data science student at IIT Mandi with a focus on building intuitive and innovative applications. I enjoy exploring new technologies and solving complex problems with clean, efficient code.',
      email: 'aman@example.com',
      phone: '+91 12345 67890',
      location: 'IIT Mandi, India',
      linkedinUrl: 'https://linkedin.com/in/amansikarwar',
      githubUrl: 'https://github.com/amansikarwar',
      resumeUrl: '',
      profileImageUrl: 'assets/Aman Sikarwar.png',
      roles: ['Flutter Developer', 'Data Scientist', 'Problem Solver'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _experiences = [
      Experience(
        id: '1',
        company: 'Syncubator',
        role: 'Software Development Intern',
        duration: 'August 2024 - Present',
        startDate: '2024-08-01',
        endDate: null,
        description:
            'Developing cross-platform applications for neonatal incubator',
        responsibilities: [
          'Developing cross-platform mobile and console display applications for a next-generation neonatal incubator using Flutter and Dart.',
          'Architecting cloud infrastructure with AWS (S3, EC2, Lambda, DynamoDB, API Gateway) for real-time data sync and secure storage.',
          'Building embedded Linux applications for incubator control systems.',
        ],
        skills: ['Flutter', 'Dart', 'AWS', 'Embedded Linux'],
        iconColor: '#64FFDA',
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Experience(
        id: '2',
        company: 'Inter IIT Tech Meet, IIT Madras',
        role: 'Back-end Developer',
        duration: 'October 2023 - December 2023',
        startDate: '2023-10-01',
        endDate: '2023-12-01',
        description: 'Backend development for hackathon project',
        responsibilities: [
          'Developed backend for Trumio using FastAPI and Python.',
          'Integrated an AI chatbot with Langchain framework.',
          'Contributed to the team that secured a top position in the hackathon.',
        ],
        skills: ['Python', 'FastAPI', 'Langchain', 'AI'],
        iconColor: '#FF7597',
        sortOrder: 2,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _setLoadingState(LoadingState.loaded);
  } // CRUD Methods for Admin Dashboard

  // Personal Info CRUD
  Future<void> updatePersonalInfo(PersonalInfo personalInfo) async {
    try {
      _setLoadingState(LoadingState.loading);

      // For now, just update locally since Supabase CRUD methods aren't implemented
      // TODO: Implement Supabase CRUD methods
      debugPrint(
        'Updating personal info locally (Supabase CRUD not implemented)',
      );
      _personalInfo = personalInfo;

      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to update personal info: $e');
      rethrow;
    }
  }

  // Experience CRUD
  Future<void> addExperience(Experience experience) async {
    try {
      _setLoadingState(LoadingState.loading);

      // Create new experience with generated ID and timestamps
      final newExperience = Experience(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        company: experience.company,
        role: experience.role,
        duration: experience.duration,
        startDate: experience.startDate,
        endDate: experience.endDate,
        description: experience.description,
        responsibilities: experience.responsibilities,
        skills: experience.skills,
        iconColor: experience.iconColor,
        sortOrder: _experiences.length + 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _experiences.add(newExperience);
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to add experience: $e');
      rethrow;
    }
  }

  Future<void> updateExperience(Experience experience) async {
    try {
      _setLoadingState(LoadingState.loading);

      final index = _experiences.indexWhere((e) => e.id == experience.id);
      if (index != -1) {
        // Create updated experience with new timestamp
        final updatedExperience = Experience(
          id: experience.id,
          company: experience.company,
          role: experience.role,
          duration: experience.duration,
          startDate: experience.startDate,
          endDate: experience.endDate,
          description: experience.description,
          responsibilities: experience.responsibilities,
          skills: experience.skills,
          iconColor: experience.iconColor,
          sortOrder: experience.sortOrder,
          isActive: experience.isActive,
          createdAt: experience.createdAt,
          updatedAt: DateTime.now(),
        );

        _experiences[index] = updatedExperience;
      }

      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to update experience: $e');
      rethrow;
    }
  }

  Future<void> deleteExperience(String experienceId) async {
    try {
      _setLoadingState(LoadingState.loading);

      _experiences.removeWhere((e) => e.id == experienceId);

      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to delete experience: $e');
      rethrow;
    }
  }

  // Project CRUD
  Future<void> addProject(Project project) async {
    try {
      _setLoadingState(LoadingState.loading);

      // Create new project with generated ID and timestamps
      final newProject = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: project.title,
        description: project.description,
        longDescription: project.longDescription,
        githubUrl: project.githubUrl,
        liveUrl: project.liveUrl,
        technologies: project.technologies,
        features: project.features,
        imageUrl: project.imageUrl,
        screenshots: project.screenshots.isEmpty ? [] : project.screenshots,
        stars: project.stars,
        commitCount: project.commitCount,
        status: project.status.isEmpty ? 'completed' : project.status,
        sortOrder: _projects.length + 1,
        isActive: true,
        isFeatured: project.isFeatured,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _projects.add(newProject);
      if (newProject.isFeatured) {
        _featuredProjects.add(newProject);
      }

      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to add project: $e');
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      _setLoadingState(LoadingState.loading);

      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        // Create updated project with new timestamp
        final updatedProject = Project(
          id: project.id,
          title: project.title,
          description: project.description,
          longDescription: project.longDescription,
          githubUrl: project.githubUrl,
          liveUrl: project.liveUrl,
          technologies: project.technologies,
          features: project.features,
          imageUrl: project.imageUrl,
          screenshots: project.screenshots,
          stars: project.stars,
          commitCount: project.commitCount,
          status: project.status,
          sortOrder: project.sortOrder,
          isActive: project.isActive,
          isFeatured: project.isFeatured,
          createdAt: project.createdAt,
          updatedAt: DateTime.now(),
        );

        _projects[index] = updatedProject;

        // Update featured projects list
        _featuredProjects.removeWhere((p) => p.id == project.id);
        if (updatedProject.isFeatured) {
          _featuredProjects.add(updatedProject);
        }
      }

      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to update project: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      _setLoadingState(LoadingState.loading);

      _projects.removeWhere((p) => p.id == projectId);
      _featuredProjects.removeWhere((p) => p.id == projectId);

      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to delete project: $e');
      rethrow;
    }
  }

  // Skill CRUD
  Future<void> addSkill(Skill skill) async {
    try {
      _setLoadingState(LoadingState.loading);

      // Create new skill with generated ID and timestamps
      final newSkill = Skill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: skill.name,
        category: skill.category,
        proficiency: skill.proficiency,
        iconName: skill.iconName,
        color: skill.color,
        sortOrder: _skills.length + 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _skills.add(newSkill);
      _updateSkillsByCategory();
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to add skill: $e');
      rethrow;
    }
  }

  Future<void> updateSkill(Skill skill) async {
    try {
      _setLoadingState(LoadingState.loading);

      final index = _skills.indexWhere((s) => s.id == skill.id);
      if (index != -1) {
        // Create updated skill with new timestamp
        final updatedSkill = Skill(
          id: skill.id,
          name: skill.name,
          category: skill.category,
          proficiency: skill.proficiency,
          iconName: skill.iconName,
          color: skill.color,
          sortOrder: skill.sortOrder,
          isActive: skill.isActive,
          createdAt: skill.createdAt,
          updatedAt: DateTime.now(),
        );

        _skills[index] = updatedSkill;
      }

      _updateSkillsByCategory();
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to update skill: $e');
      rethrow;
    }
  }

  Future<void> deleteSkill(String skillId) async {
    try {
      _setLoadingState(LoadingState.loading);

      _skills.removeWhere((s) => s.id == skillId);
      _updateSkillsByCategory();

      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to delete skill: $e');
      rethrow;
    }
  }

  // Helper method to update skills by category
  void _updateSkillsByCategory() {
    _skillsByCategory.clear();
    for (final skill in _skills) {
      _skillsByCategory.putIfAbsent(skill.category, () => []).add(skill);
    }
  }
}
