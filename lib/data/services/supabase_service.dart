import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:portfolio_app/core/config/supabase_config.dart';
import 'package:portfolio_app/core/services/error_handler.dart';
import 'package:portfolio_app/core/services/logging_service.dart';
import 'package:portfolio_app/data/models/personal_info.dart';
import 'package:portfolio_app/data/models/experience.dart';
import 'package:portfolio_app/data/models/skill.dart';
import 'package:portfolio_app/data/models/project.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    _client ??= SupabaseClient(
      SupabaseConfig.supabaseUrl,
      SupabaseConfig.supabaseAnonKey,
    );
    return _client!;
  }

  static Future<void> initialize() async {
    try {
      LoggingService.info('Initializing Supabase client');

      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      ).timeout(AppConfig.networkTimeout);

      LoggingService.info('Supabase client initialized successfully');
    } catch (e, stackTrace) {
      final error = NetworkException(
        'Failed to initialize Supabase client',
        originalError: e,
        stackTrace: stackTrace,
      );

      LoggingService.error(
        'Supabase initialization failed',
        error: error,
        stackTrace: stackTrace,
      );

      throw error;
    }
  }

  // Personal Info Methods
  static Future<Result<PersonalInfo?>> getPersonalInfo() async {
    try {
      LoggingService.debug('Fetching personal info from database');

      final response = await client
          .from('personal_info')
          .select()
          .eq('is_active', true)
          .maybeSingle()
          .timeout(AppConfig.databaseTimeout);

      if (response != null) {
        final personalInfo = PersonalInfo.fromJson(response);
        LoggingService.info('Personal info fetched successfully');
        return Result.success(personalInfo);
      }

      LoggingService.warning('No active personal info found');
      return Result.success(null);
    } catch (e, stackTrace) {
      final error = DatabaseException(
        'Failed to fetch personal info',
        originalError: e,
        stackTrace: stackTrace,
      );

      LoggingService.error(
        'Error fetching personal info',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.failure(error);
    }
  }

  // Experience Methods
  static Future<Result<List<Experience>>> getExperiences() async {
    try {
      LoggingService.debug('Fetching experiences from database');

      final response = await client
          .from('experiences')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .timeout(AppConfig.databaseTimeout);

      final experiences = response
          .map((json) => Experience.fromJson(json))
          .toList();
      LoggingService.info(
        'Fetched ${experiences.length} experiences successfully',
      );
      return Result.success(experiences);
    } catch (e, stackTrace) {
      final error = DatabaseException(
        'Failed to fetch experiences',
        originalError: e,
        stackTrace: stackTrace,
      );

      LoggingService.error(
        'Error fetching experiences',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.failure(error);
    }
  }

  // Skills Methods
  static Future<Result<List<Skill>>> getSkills() async {
    try {
      LoggingService.debug('Fetching skills from database');

      final response = await client
          .from('skills')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .timeout(AppConfig.databaseTimeout);

      final skills = response.map((json) => Skill.fromJson(json)).toList();
      LoggingService.info('Fetched ${skills.length} skills successfully');
      return Result.success(skills);
    } catch (e, stackTrace) {
      final error = DatabaseException(
        'Failed to fetch skills',
        originalError: e,
        stackTrace: stackTrace,
      );

      LoggingService.error(
        'Error fetching skills',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.failure(error);
    }
  }

  static Future<Result<Map<String, List<Skill>>>> getSkillsByCategory() async {
    try {
      LoggingService.debug('Fetching skills by category');

      final skillsResult = await getSkills();
      if (skillsResult.isFailure) {
        return Result.failure(skillsResult.error!);
      }

      final skills = skillsResult.value;
      final Map<String, List<Skill>> categorizedSkills = {};

      for (final skill in skills) {
        if (!categorizedSkills.containsKey(skill.category)) {
          categorizedSkills[skill.category] = [];
        }
        categorizedSkills[skill.category]!.add(skill);
      }

      LoggingService.info(
        'Categorized ${skills.length} skills into ${categorizedSkills.length} categories',
      );
      return Result.success(categorizedSkills);
    } catch (e, stackTrace) {
      final error = DatabaseException(
        'Failed to categorize skills',
        originalError: e,
        stackTrace: stackTrace,
      );

      LoggingService.error(
        'Error categorizing skills',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.failure(error);
    }
  }

  // Projects Methods
  static Future<Result<List<Project>>> getProjects() async {
    try {
      LoggingService.debug('Fetching projects from database');

      final response = await client
          .from('projects')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .timeout(AppConfig.databaseTimeout);

      final projects = response.map((json) => Project.fromJson(json)).toList();
      LoggingService.info('Fetched ${projects.length} projects successfully');
      return Result.success(projects);
    } catch (e, stackTrace) {
      final error = DatabaseException(
        'Failed to fetch projects',
        originalError: e,
        stackTrace: stackTrace,
      );

      LoggingService.error(
        'Error fetching projects',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.failure(error);
    }
  }

  static Future<Result<List<Project>>> getFeaturedProjects() async {
    try {
      LoggingService.debug('Fetching featured projects from database');

      final response = await client
          .from('projects')
          .select()
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('sort_order', ascending: true)
          .timeout(AppConfig.databaseTimeout);

      final projects = response.map((json) => Project.fromJson(json)).toList();
      LoggingService.info(
        'Fetched ${projects.length} featured projects successfully',
      );
      return Result.success(projects);
    } catch (e, stackTrace) {
      final error = DatabaseException(
        'Failed to fetch featured projects',
        originalError: e,
        stackTrace: stackTrace,
      );

      LoggingService.error(
        'Error fetching featured projects',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.failure(error);
    }
  }

  // Storage Methods
  static Future<Result<String>> getFileUrl(
    String bucket,
    String filePath,
  ) async {
    try {
      LoggingService.debug('Getting file URL for: $bucket/$filePath');

      final url = client.storage.from(bucket).getPublicUrl(filePath);
      LoggingService.info('File URL retrieved successfully');
      return Result.success(url);
    } catch (e, stackTrace) {
      final error = DatabaseException(
        'Failed to get file URL',
        originalError: e,
        stackTrace: stackTrace,
      );

      LoggingService.error(
        'Error getting file URL',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.failure(error);
    }
  }

  static Future<Result<String>> uploadFile(
    String bucket,
    String filePath,
    List<int> fileBytes,
  ) async {
    try {
      LoggingService.debug('Uploading file: $bucket/$filePath');

      await client.storage
          .from(bucket)
          .uploadBinary(filePath, Uint8List.fromList(fileBytes))
          .timeout(AppConfig.networkTimeout);

      final urlResult = await getFileUrl(bucket, filePath);
      if (urlResult.isFailure) {
        return Result.failure(urlResult.error!);
      }

      LoggingService.info('File uploaded successfully');
      return Result.success(urlResult.value);
    } catch (e, stackTrace) {
      final error = NetworkException(
        'Failed to upload file',
        originalError: e,
        stackTrace: stackTrace,
      );

      LoggingService.error(
        'Error uploading file',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.failure(error);
    }
  }

  // Cache-related methods
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  static T? _getCached<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp != null &&
        DateTime.now().difference(timestamp) < _cacheExpiry &&
        _cache.containsKey(key)) {
      return _cache[key] as T;
    }
    return null;
  }

  static void _setCache<T>(String key, T value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  static Future<Result<PersonalInfo?>> getCachedPersonalInfo() async {
    const key = 'personal_info';
    final cached = _getCached<PersonalInfo>(key);
    if (cached != null) return Result.success(cached);

    final result = await getPersonalInfo();
    if (result.isSuccess && result.data != null) {
      _setCache(key, result.data!);
    }
    return result;
  }

  static Future<Result<List<Experience>>> getCachedExperiences() async {
    const key = 'experiences';
    final cached = _getCached<List<Experience>>(key);
    if (cached != null) return Result.success(cached);

    final result = await getExperiences();
    if (result.isSuccess) {
      _setCache(key, result.value);
    }
    return result;
  }

  static Future<Result<List<Skill>>> getCachedSkills() async {
    const key = 'skills';
    final cached = _getCached<List<Skill>>(key);
    if (cached != null) return Result.success(cached);

    final result = await getSkills();
    if (result.isSuccess) {
      _setCache(key, result.value);
    }
    return result;
  }

  static Future<Result<List<Project>>> getCachedProjects() async {
    const key = 'projects';
    final cached = _getCached<List<Project>>(key);
    if (cached != null) return Result.success(cached);

    final result = await getProjects();
    if (result.isSuccess) {
      _setCache(key, result.value);
    }
    return result;
  }

  // Contact Form Methods
  static Future<Result<bool>> submitContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      LoggingService.debug('Submitting contact message from: $email');

      await client
          .from('contact_messages')
          .insert({
            'name': name,
            'email': email,
            'subject': subject,
            'message': message,
            'created_at': DateTime.now().toIso8601String(),
            'is_read': false,
          })
          .timeout(AppConfig.databaseTimeout);

      LoggingService.info('Contact message submitted successfully');
      return Result.success(true);
    } catch (e, stackTrace) {
      final error = DatabaseException(
        'Failed to submit contact message',
        originalError: e,
        stackTrace: stackTrace,
      );

      LoggingService.error(
        'Error submitting contact message',
        error: error,
        stackTrace: stackTrace,
      );

      return Result.failure(error);
    }
  }

  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
