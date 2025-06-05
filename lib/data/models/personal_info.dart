class PersonalInfo {
  final String id;
  final String name;
  final String title;
  final String aboutMe;
  final String email;
  final String phone;
  final String location;
  final String linkedinUrl;
  final String githubUrl;
  final String resumeUrl;
  final String profileImageUrl;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonalInfo({
    required this.id,
    required this.name,
    required this.title,
    required this.aboutMe,
    required this.email,
    required this.phone,
    required this.location,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.resumeUrl,
    required this.profileImageUrl,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      aboutMe: json['about_me'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      linkedinUrl: json['linkedin_url'] ?? '',
      githubUrl: json['github_url'] ?? '',
      resumeUrl: json['resume_url'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'about_me': aboutMe,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'resume_url': resumeUrl,
      'profile_image_url': profileImageUrl,
      'roles': roles,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
