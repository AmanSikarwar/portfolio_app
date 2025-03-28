import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:portfolio_app/data/models/github_project.dart';

class GitHubService {
  static Future<List<GitHubProject>> getProjects() async {
    final response = await http.get(
      Uri.parse('https://api.github.com/users/amansikarwar/repos'),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      final projects =
          jsonResponse.map((data) => GitHubProject.fromJson(data)).toList();

      final List<GitHubProject> projectsWithCommits = [];

      for (var project in projects) {
        try {
          final commitCount = await _getCommitCount(project.title);
          projectsWithCommits.add(
            GitHubProject(
              title: project.title,
              description: project.description,
              url: project.url,
              stars: project.stars,
              topics: project.topics,
              commitCount: commitCount,
            ),
          );
        } catch (e) {
          projectsWithCommits.add(project);
        }
      }

      projectsWithCommits.sort(
        (a, b) => b.commitCount.compareTo(a.commitCount),
      );

      return projectsWithCommits;
    } else {
      throw Exception('Failed to load projects');
    }
  }

  static Future<int> _getCommitCount(String repoName) async {
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
      final commitResponse = await http.get(
        Uri.parse(
          'https://api.github.com/repos/amansikarwar/$repoName/commits?per_page=1',
        ),
      );

      if (commitResponse.statusCode == 200 &&
          commitResponse.headers.containsKey('link')) {
        final linkHeader = commitResponse.headers['link'] ?? '';
        final regex = RegExp(r'page=(\d+)>; rel="last"');
        final match = regex.firstMatch(linkHeader);

        if (match != null) {
          return int.parse(match.group(1) ?? '0');
        }
      }

      return 0;
    }
  }
}
