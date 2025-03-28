import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio_app/data/services/github_service.dart';
import 'package:portfolio_app/data/models/github_project.dart';
import 'package:portfolio_app/widgets/colorful_chip.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';
import 'package:portfolio_app/core/utils/image_helper.dart';
import 'package:flutter/services.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection>
    with SingleTickerProviderStateMixin {
  Future<List<GitHubProject>>? _projectsFuture;
  late AnimationController _animationController;
  bool _isLoaded = false;

  final List<Map<String, dynamic>> featuredProjects = [
    {
      'title': 'Real-Time Health Data Visualization App',
      'description':
          'Displays patient vital signs in real-time using Flutter, Dart, MQTT, and BLE.',
      'technologies': ['Flutter', 'Dart', 'MQTT', 'BLE'],
      'link': 'https://github.com/amansikarwar/health-app',
      'repoName': 'health-app',
      'isFeatured': true,
    },
    {
      'title': 'Automated Captive Portal Login',
      'description':
          'CLI tool to automate captive portal logins, reducing login time by 90%.',
      'technologies': ['Rust', 'Systemd', 'Launchd'],
      'link': 'https://github.com/amansikarwar/captive-portal-login',
      'repoName': 'captive-portal-login',
      'isFeatured': true,
    },
    {
      'title': 'IIT Mandi Institute App',
      'description':
          'Mobile app for gymkhana resources and event management with Flutter and Firebase.',
      'technologies': ['Flutter', 'Dart', 'Firebase'],
      'link': 'https://github.com/amansikarwar/iit-mandi-app',
      'repoName': 'iit-mandi-app',
      'isFeatured': true,
    },
  ];

  final Map<String, String?> _featuredProjectImages = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _projectsFuture = GitHubService.getProjects();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoaded = true);
    });

    _loadFeaturedProjectImages();
  }

  Future<void> _loadFeaturedProjectImages() async {
    for (final project in featuredProjects) {
      if (project.containsKey('repoName')) {
        try {
          final imageUrl = await _getReadmeImageUrl(project['repoName']);
          if (imageUrl != null) {
            setState(() {
              _featuredProjectImages[project['repoName']] = imageUrl;
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading image for ${project['title']}: $e');
          }
        }
      }
    }
  }

  Future<String?> _getReadmeImageUrl(String repoName) async {
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 1024;
    final bool isTablet = screenWidth > 600 && screenWidth <= 1024;
    final bool isMobile = screenWidth <= 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [colorScheme.surfaceContainerHighest, colorScheme.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedHeader(context),

          const SizedBox(height: 32),

          Row(
            children: [
              Icon(Icons.star, color: AppTheme.accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Featured Projects',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Divider(color: AppTheme.accentColor.withAlpha(77)),
              ),
            ],
          ),

          const SizedBox(height: 24),

          AnimatedOpacity(
            opacity: _isLoaded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuad,
            child: _buildFeaturedProjectsGrid(isDesktop, isTablet),
          ),

          const SizedBox(height: 48),

          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.github,
                color: AppTheme.accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'GitHub Projects',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Divider(color: AppTheme.accentColor.withAlpha(77)),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildGitHubProjectsView(isDesktop, isTablet),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    return ShaderMask(
      shaderCallback:
          (bounds) => LinearGradient(
            colors: [
              AppTheme.primarySeed,
              AppTheme.accentColor,
              AppTheme.tertiaryColor,
              AppTheme.primarySeed,
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            tileMode: TileMode.mirror,
            transform: GradientRotation(
              _animationController.value * 2 * 3.14159,
            ),
          ).createShader(bounds),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projects',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A showcase of my recent work and personal projects',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProjectsGrid(bool isDesktop, bool isTablet) {
    final int gridColumns = isDesktop ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        childAspectRatio: 1.1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: featuredProjects.length,
      itemBuilder: (context, index) {
        final projectData = Map<String, dynamic>.from(featuredProjects[index]);
        if (projectData.containsKey('repoName') &&
            _featuredProjectImages.containsKey(projectData['repoName'])) {
          projectData['readmeImageUrl'] =
              _featuredProjectImages[projectData['repoName']];
        }

        return EnhancedProjectCard(project: projectData, index: index);
      },
    );
  }

  Widget _buildGitHubProjectsView(bool isDesktop, bool isTablet) {
    final int gridColumns = isDesktop ? 3 : (isTablet ? 2 : 1);

    final List<String> featuredProjectUrls =
        featuredProjects.map((project) => project['link'] as String).toList();

    return FutureBuilder<List<GitHubProject>>(
      future: _projectsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading projects: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No GitHub projects found'),
          );
        } else {
          final projects =
              snapshot.data!
                  .where(
                    (project) => !featuredProjectUrls.contains(project.url),
                  )
                  .take(6)
                  .toList();

          if (projects.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('All projects are featured above'),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return EnhancedGitHubCard(
                    project: projects[index],
                    index: index,
                  );
                },
              ),

              const SizedBox(height: 32),

              Center(
                child: ElevatedButton.icon(
                  onPressed:
                      () => launchUrl(
                        Uri.parse(
                          'https://github.com/amansikarwar?tab=repositories',
                        ),
                      ),
                  icon: const FaIcon(FontAwesomeIcons.github, size: 16),
                  label: const Text('View More on GitHub'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class EnhancedProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
  final int index;

  const EnhancedProjectCard({
    super.key,
    required this.project,
    required this.index,
  });

  @override
  State<EnhancedProjectCard> createState() => _EnhancedProjectCardState();
}

class _EnhancedProjectCardState extends State<EnhancedProjectCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 600;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: 1.0,
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: Card(
              elevation: _isHovered ? 8 : (_isPressed ? 10 : 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {},
                  splashColor: AppTheme.accentColor.withAlpha(30),
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.surfaceContainerHigh,
                          colorScheme.surfaceContainerLow,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _isHovered || _isPressed
                                ? AppTheme.accentColor.withAlpha(
                                  _isPressed ? 150 : 100,
                                )
                                : Colors.transparent,
                        width: _isPressed ? 2.5 : 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.project.containsKey('readmeImageUrl') &&
                            widget.project['readmeImageUrl'] != null)
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                            ),
                            child: ImageHelper.getImage(
                              path: widget.project['readmeImageUrl'],
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (widget.project.containsKey('image') &&
                            widget.project['image'] != null)
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                            ),
                            child: ImageHelper.getImage(
                              path: widget.project['image'],
                              fit: BoxFit.cover,
                            ),
                          ),

                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 12 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.project['title'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (widget.project['category'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentColor.withAlpha(
                                            40,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          widget.project['category'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.accentColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  widget.project['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 16),

                                ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 50),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children:
                                        (widget.project['technologies'] as List)
                                            .take(3)
                                            .map<Widget>(
                                              (tech) => ColorfulChip(
                                                label: tech.toString(),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),

                                const Spacer(),

                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        _isHovered || _isPressed ? 16 : 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _isHovered || _isPressed
                                            ? AppTheme.accentColor
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: AppTheme.accentColor,
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      launchUrl(
                                        Uri.parse(widget.project['link']),
                                      );
                                    },
                                    splashColor: Colors.white24,
                                    highlightColor: Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.open_in_new,
                                          size: 16,
                                          color:
                                              _isHovered || _isPressed
                                                  ? Colors.black
                                                  : AppTheme.accentColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'View Project',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                _isHovered || _isPressed
                                                    ? Colors.black
                                                    : AppTheme.accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EnhancedGitHubCard extends StatefulWidget {
  final GitHubProject project;
  final int index;

  const EnhancedGitHubCard({
    super.key,
    required this.project,
    required this.index,
  });

  @override
  State<EnhancedGitHubCard> createState() => _EnhancedGitHubCardState();
}

class _EnhancedGitHubCardState extends State<EnhancedGitHubCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 600;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: 1.0,
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: Card(
              elevation: _isHovered ? 8 : (_isPressed ? 10 : 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {},
                  splashColor: AppTheme.accentColor.withAlpha(30),
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.surfaceContainerHigh,
                          colorScheme.surfaceContainerLow,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _isHovered || _isPressed
                                ? AppTheme.accentColor.withAlpha(
                                  _isPressed ? 150 : 100,
                                )
                                : Colors.transparent,
                        width: _isPressed ? 2.5 : 2,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final hasImage =
                              widget.project.readmeImageUrl != null;
                          final imageHeight = hasImage ? 120.0 : 0.0;
                          final imageMargin = hasImage ? 12.0 : 0.0;
                          final titleHeight = 40.0;
                          final descHeight = 30.0;
                          final statsHeight = 30.0;
                          final topicsHeight =
                              widget.project.topics.isNotEmpty ? 32.0 : 0.0;
                          final buttonHeight = 40.0;
                          final totalSpacing = 38.0;

                          final totalNeededHeight =
                              imageHeight +
                              imageMargin +
                              titleHeight +
                              descHeight +
                              statsHeight +
                              topicsHeight +
                              buttonHeight +
                              totalSpacing;

                          final scaleFactor =
                              totalNeededHeight > constraints.maxHeight
                                  ? constraints.maxHeight / totalNeededHeight
                                  : 1.0;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasImage)
                                SizedBox(
                                  height: imageHeight * scaleFactor,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ImageHelper.getImage(
                                      path: widget.project.readmeImageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                              if (hasImage)
                                SizedBox(height: 12.0 * scaleFactor),

                              SizedBox(
                                height: titleHeight * scaleFactor,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6 * scaleFactor),
                                      decoration: BoxDecoration(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.github,
                                        color: Colors.white,
                                        size: 16 * scaleFactor,
                                      ),
                                    ),
                                    SizedBox(width: 8 * scaleFactor),
                                    Expanded(
                                      child: Text(
                                        widget.project.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16 * scaleFactor,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 8 * scaleFactor),

                              SizedBox(
                                height: descHeight * scaleFactor,
                                child: Text(
                                  widget.project.description,
                                  style: TextStyle(
                                    fontSize: 13 * scaleFactor,
                                    color: Colors.white70,
                                    height: 1.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              SizedBox(height: 8 * scaleFactor),

                              SizedBox(
                                height: statsHeight * scaleFactor,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildGitHubStat(
                                      FontAwesomeIcons.codeBranch,
                                      '${widget.project.commitCount}',
                                      scaleFactor,
                                    ),
                                    SizedBox(width: 10 * scaleFactor),
                                    _buildGitHubStat(
                                      FontAwesomeIcons.star,
                                      widget.project.stars.toString(),
                                      scaleFactor,
                                    ),
                                  ],
                                ),
                              ),

                              if (widget.project.topics.isNotEmpty)
                                SizedBox(height: 6 * scaleFactor),

                              if (widget.project.topics.isNotEmpty)
                                SizedBox(
                                  height: topicsHeight * scaleFactor,
                                  child:
                                      widget.project.topics
                                          .take(1)
                                          .map(
                                            (topic) =>
                                                ColorfulChip(label: topic),
                                          )
                                          .first,
                                ),

                              Spacer(),
                              SizedBox(
                                height: buttonHeight * scaleFactor,
                                child: _buildGitHubButton(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGitHubButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isHovered || _isPressed ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            _isHovered || _isPressed
                ? AppTheme.accentColor
                : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppTheme.accentColor,
          width: _isPressed ? 2.5 : 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          launchUrl(Uri.parse(widget.project.url));
        },
        splashColor: Colors.white24,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisSize:
              _isHovered || _isPressed ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment:
              _isHovered || _isPressed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
          children: [
            FaIcon(
              FontAwesomeIcons.github,
              size: 14,
              color:
                  _isHovered || _isPressed
                      ? Colors.black
                      : AppTheme.accentColor,
            ),
            const SizedBox(width: 6),
            Text(
              'View on GitHub',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color:
                    _isHovered || _isPressed
                        ? Colors.black
                        : AppTheme.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGitHubStat(IconData icon, String text, double scaleFactor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8 * scaleFactor,
        vertical: 4 * scaleFactor,
      ),
      decoration: BoxDecoration(
        color: AppTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16 * scaleFactor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 10 * scaleFactor, color: AppTheme.accentColor),
          SizedBox(width: 4 * scaleFactor),
          Text(
            text,
            style: TextStyle(
              fontSize: 11 * scaleFactor,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
