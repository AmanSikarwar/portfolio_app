class Project {
  final String id;
  final String title;
  final String description;
  final String? longDescription;
  final String githubUrl;
  final String? liveUrl;
  final List<String> technologies;
  final List<String> features;
  final String? imageUrl;
  final List<String> screenshots;
  final int stars;
  final int? commitCount;
  final String status; // 'completed', 'in-progress', 'planned'
  final int sortOrder;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    this.longDescription,
    required this.githubUrl,
    this.liveUrl,
    required this.technologies,
    required this.features,
    this.imageUrl,
    required this.screenshots,
    required this.stars,
    this.commitCount,
    required this.status,
    required this.sortOrder,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      longDescription: json['long_description'],
      githubUrl: json['github_url'] ?? '',
      liveUrl: json['live_url'],
      technologies: List<String>.from(json['technologies'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      imageUrl: json['image_url'],
      screenshots: List<String>.from(json['screenshots'] ?? []),
      stars: json['stars'] ?? 0,
      commitCount: json['commit_count'],
      status: json['status'] ?? 'completed',
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'long_description': longDescription,
      'github_url': githubUrl,
      'live_url': liveUrl,
      'technologies': technologies,
      'features': features,
      'image_url': imageUrl,
      'screenshots': screenshots,
      'stars': stars,
      'commit_count': commitCount,
      'status': status,
      'sort_order': sortOrder,
      'is_active': isActive,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
