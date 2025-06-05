import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:portfolio_app/core/config/supabase_config.dart';
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
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // Personal Info Methods
  static Future<PersonalInfo?> getPersonalInfo() async {
    try {
      final response = await client
          .from('personal_info')
          .select()
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        return PersonalInfo.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch personal info: $e');
    }
  }

  // Experience Methods
  static Future<List<Experience>> getExperiences() async {
    try {
      final response = await client
          .from('experiences')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return response.map((json) => Experience.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch experiences: $e');
    }
  }

  // Skills Methods
  static Future<List<Skill>> getSkills() async {
    try {
      final response = await client
          .from('skills')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return response.map((json) => Skill.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch skills: $e');
    }
  }

  static Future<Map<String, List<Skill>>> getSkillsByCategory() async {
    try {
      final skills = await getSkills();
      final Map<String, List<Skill>> categorizedSkills = {};

      for (final skill in skills) {
        if (!categorizedSkills.containsKey(skill.category)) {
          categorizedSkills[skill.category] = [];
        }
        categorizedSkills[skill.category]!.add(skill);
      }

      return categorizedSkills;
    } catch (e) {
      throw Exception('Failed to fetch categorized skills: $e');
    }
  }

  // Projects Methods
  static Future<List<Project>> getProjects() async {
    try {
      final response = await client
          .from('projects')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return response.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  static Future<List<Project>> getFeaturedProjects() async {
    try {
      final response = await client
          .from('projects')
          .select()
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('sort_order', ascending: true);

      return response.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured projects: $e');
    }
  }

  // Storage Methods
  static Future<String> getFileUrl(String bucket, String filePath) async {
    try {
      return client.storage.from(bucket).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to get file URL: $e');
    }
  }

  static Future<String> uploadFile(
    String bucket,
    String filePath,
    List<int> fileBytes,
  ) async {
    try {
      await client.storage
          .from(bucket)
          .uploadBinary(filePath, Uint8List.fromList(fileBytes));
      return getFileUrl(bucket, filePath);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
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

  static Future<PersonalInfo?> getCachedPersonalInfo() async {
    const key = 'personal_info';
    final cached = _getCached<PersonalInfo>(key);
    if (cached != null) return cached;

    final result = await getPersonalInfo();
    if (result != null) _setCache(key, result);
    return result;
  }

  static Future<List<Experience>> getCachedExperiences() async {
    const key = 'experiences';
    final cached = _getCached<List<Experience>>(key);
    if (cached != null) return cached;

    final result = await getExperiences();
    _setCache(key, result);
    return result;
  }

  static Future<List<Skill>> getCachedSkills() async {
    const key = 'skills';
    final cached = _getCached<List<Skill>>(key);
    if (cached != null) return cached;

    final result = await getSkills();
    _setCache(key, result);
    return result;
  }

  static Future<List<Project>> getCachedProjects() async {
    const key = 'projects';
    final cached = _getCached<List<Project>>(key);
    if (cached != null) return cached;

    final result = await getProjects();
    _setCache(key, result);
    return result;
  }

  // Contact Form Methods
  static Future<void> submitContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      await client.from('contact_messages').insert({
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    } catch (e) {
      throw Exception('Failed to submit contact message: $e');
    }
  }

  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
