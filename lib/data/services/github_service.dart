import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:portfolio_app/data/models/github_project.dart';

class GitHubService {
  static List<GitHubProject>? _cachedProjects;

  static Future<List<GitHubProject>> getProjects() async {
    if (_cachedProjects != null && _cachedProjects!.isNotEmpty) {
      return _cachedProjects!;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/users/amansikarwar/repos'),
        headers: {
          'If-None-Match': '',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        jsonResponse =
            jsonResponse.where((repo) => repo['fork'] != true).toList();

        final projects =
            jsonResponse.map((data) => GitHubProject.fromJson(data)).toList();

        final List<GitHubProject> projectsWithDetails = [];

        for (var project in projects) {
          try {
            final commitCount = await _getCommitCount(project.title);
            final readmeImageUrl = await _getReadmeImageUrl(project.title);

            projectsWithDetails.add(
              GitHubProject(
                title: project.title,
                description: project.description,
                url: project.url,
                stars: project.stars,
                topics: project.topics,
                commitCount: commitCount,
                readmeImageUrl: readmeImageUrl,
              ),
            );
          } catch (e) {
            projectsWithDetails.add(project);
          }
        }

        projectsWithDetails.sort(
          (a, b) => b.commitCount.compareTo(a.commitCount),
        );

        _cachedProjects = projectsWithDetails;
        return projectsWithDetails;
      } else if (response.statusCode == 403 &&
          response.body.contains("API rate limit exceeded")) {
        log('GitHub API rate limit exceeded: ${response.statusCode}');
        return _getFallbackProjects();
      } else {
        log('Failed to load projects: ${response.statusCode}');
        log('Response body: ${response.body}');
        return _getFallbackProjects();
      }
    } catch (e) {
      log('Exception when fetching GitHub projects: $e');
      return _getFallbackProjects();
    }
  }

  static List<GitHubProject> _getFallbackProjects() {
    if (_cachedProjects != null && _cachedProjects!.isNotEmpty) {
      return _cachedProjects!;
    }

    final fallbackProjects = [
      GitHubProject(
        title: 'portfolio_app',
        description: 'Personal portfolio website built with Flutter',
        url: 'https://github.com/amansikarwar/portfolio_app',
        stars: 5,
        topics: ['flutter', 'dart', 'portfolio', 'web'],
        commitCount: 24,
      ),
      GitHubProject(
        title: 'health-app',
        description: 'Real-time health data visualization application',
        url: 'https://github.com/amansikarwar/health-app',
        stars: 8,
        topics: ['flutter', 'health', 'data-visualization'],
        commitCount: 42,
      ),
      GitHubProject(
        title: 'captive-portal-login',
        description: 'CLI tool to automate captive portal logins',
        url: 'https://github.com/amansikarwar/captive-portal-login',
        stars: 12,
        topics: ['rust', 'cli', 'networking'],
        commitCount: 15,
      ),
      GitHubProject(
        title: 'iit-mandi-app',
        description: 'Mobile app for IIT Mandi resources and events',
        url: 'https://github.com/amansikarwar/iit-mandi-app',
        stars: 7,
        topics: ['flutter', 'firebase', 'education'],
        commitCount: 36,
      ),
    ];

    _cachedProjects = fallbackProjects;
    return fallbackProjects;
  }

  static Future<int> _getCommitCount(String repoName) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/amansikarwar/$repoName/stats/participation',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<int> counts = List<int>.from(data['all']);
        return counts.fold<int>(0, (sum, count) => sum + count);
      } else {
        return _getFallbackCommitCount(repoName);
      }
    } catch (e) {
      return _getFallbackCommitCount(repoName);
    }
  }

  static int _getFallbackCommitCount(String repoName) {
    int hash = 0;
    for (int i = 0; i < repoName.length; i++) {
      hash = repoName.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return 10 + (hash.abs() % 40);
  }

  static Future<String?> _getReadmeImageUrl(String repoName) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/amansikarwar/$repoName/readme'),
        headers: {'Accept': 'application/vnd.github.v3.raw'},
      );

      if (response.statusCode == 200) {
        final String content = utf8.decode(response.bodyBytes);

        final RegExp imageRegex = RegExp(r'!\[.*?\]\((.*?)\)');
        final matches = imageRegex.allMatches(content);

        if (matches.isNotEmpty) {
          String imageUrl = matches.first.group(1) ?? '';

          if (imageUrl.startsWith('./') ||
              imageUrl.startsWith('../') ||
              (!imageUrl.startsWith('http'))) {
            imageUrl =
                'https://raw.githubusercontent.com/amansikarwar/$repoName/main/${imageUrl.replaceAll(RegExp(r'^[.\/]+'), '')}';
          }

          if (imageUrl.toLowerCase().endsWith('.svg')) {
            if (imageUrl.contains('github.com') &&
                !imageUrl.contains('raw.githubusercontent.com')) {
              imageUrl = imageUrl
                  .replaceFirst('github.com', 'raw.githubusercontent.com')
                  .replaceFirst('/blob/', '/');
            }
          }

          return imageUrl;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching README for $repoName: $e');
      }
    }

    return null;
  }
}
