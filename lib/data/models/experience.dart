class Experience {
  final String id;
  final String company;
  final String role;
  final String duration;
  final String startDate;
  final String? endDate;
  final String description;
  final List<String> responsibilities;
  final List<String> skills;
  final String? iconColor;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Experience({
    required this.id,
    required this.company,
    required this.role,
    required this.duration,
    required this.startDate,
    this.endDate,
    required this.description,
    required this.responsibilities,
    required this.skills,
    this.iconColor,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] ?? '',
      company: json['company'] ?? '',
      role: json['role'] ?? '',
      duration: json['duration'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      description: json['description'] ?? '',
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      iconColor: json['icon_color'],
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'role': role,
      'duration': duration,
      'start_date': startDate,
      'end_date': endDate,
      'description': description,
      'responsibilities': responsibilities,
      'skills': skills,
      'icon_color': iconColor,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
