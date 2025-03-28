class GitHubProject {
  final String title;
  final String description;
  final String url;
  final int stars;
  final List<String> topics;
  final int commitCount;
  final String? readmeImageUrl;

  GitHubProject({
    required this.title,
    required this.description,
    required this.url,
    required this.stars,
    required this.topics,
    this.commitCount = 0,
    this.readmeImageUrl,
  });

  factory GitHubProject.fromJson(Map<String, dynamic> json) {
    return GitHubProject(
      title: json['name'],
      description: json['description'] ?? 'No description available',
      url: json['html_url'],
      stars: json['stargazers_count'] ?? 0,
      topics: List<String>.from(json['topics'] ?? []),
    );
  }
}
