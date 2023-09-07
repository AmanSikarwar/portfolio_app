class Project {
  final String title;
  final String description;
  final String? imageUrl;
  final String projectUrl;
  final List<String> tags;
  final List<String> techStack;

  const Project({
    required this.title,
    required this.description,
    this.imageUrl,
    required this.projectUrl,
    this.tags = const [],
    this.techStack = const [],
  });
}
