import 'package:flutter/material.dart';
import 'package:portfolio_app/widgets/colorful_chip.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(gradient: AppTheme.purpleBlueGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Text(
              'About Me',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                foreground:
                    Paint()
                      ..shader = LinearGradient(
                        colors: [AppTheme.accentColor, AppTheme.tertiaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 32),
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(30)),
              ),
              child: const Text(
                'I am a passionate software developer and data science student at IIT Mandi with a focus on building intuitive and innovative applications. I enjoy exploring new technologies and solving complex problems with clean, efficient code.',
                style: TextStyle(fontSize: 16, height: 1.6, letterSpacing: 0.3),
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(25),
                    Colors.white.withAlpha(10),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(50), width: 1),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1024) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: EducationWidget()),
                        SizedBox(width: 32),
                        Expanded(child: SkillsWidget()),
                      ],
                    );
                  } else if (constraints.maxWidth > 600) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: EducationWidget(isTablet: true),
                        ),
                        SizedBox(width: 20),
                        Expanded(flex: 6, child: SkillsWidget(isTablet: true)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        EducationWidget(),
                        SizedBox(height: 32),
                        SkillsWidget(),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EducationWidget extends StatelessWidget {
  final bool isTablet;

  const EducationWidget({super.key, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.school, color: AppTheme.accentColor, size: 24),
            SizedBox(width: 12),
            Text(
              'Education',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        SizedBox(height: 20),

        Container(
          padding: EdgeInsets.all(isTablet || isMobile ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            border: Border.all(
              color: AppTheme.primarySeed.withAlpha(50),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Indian Institute of Technology Mandi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bachelor of Technology - Data Science',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(230),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'November 2022 - June 2026',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'Key Courses:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Column(
                children: [
                  _buildCourseItem('Programming and Data Science'),
                  _buildCourseItem('Data Structures and Algorithms'),
                  _buildCourseItem('Machine Learning'),
                  _buildCourseItem('Database Management Systems'),
                  _buildCourseItem('Computer Networks'),
                  _buildCourseItem('Artificial Intelligence'),
                  _buildCourseItem('Deep Learning'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseItem(String course) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.chevron_right, color: AppTheme.accentColor, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              course,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkillsWidget extends StatelessWidget {
  final bool isTablet;
  final Map<String, List<String>> skills = {
    'Languages': [
      'Python',
      'Dart',
      'C++',
      'JavaScript',
      'Rust (basic)',
      'Solidity',
      'Perl',
      'SQL',
      'Bash',
    ],
    'Frameworks': [
      'Flutter',
      'Blockchain',
      'Ethereum',
      'Langchain',
      'React',
      'FastAPI',
      'NodeJS',
      'Arduino',
    ],
    'Tools/Services': [
      'Amazon Web Service',
      'Docker',
      'Git',
      'PostgreSQL',
      'MySQL',
      'SQLite',
      'Firebase',
      'Supabase',
    ],
    'Operating Systems': [
      'Linux (Ubuntu, Fedora)',
      'Arduino',
      'Raspbian OS',
      'Embedded Linux',
    ],
  };

  SkillsWidget({super.key, this.isTablet = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.code, color: AppTheme.accentColor, size: 24),
            SizedBox(width: 12),
            Text(
              'Skills',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        SizedBox(height: 20),

        Container(
          padding: EdgeInsets.all(isTablet || isMobile ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            border: Border.all(
              color: AppTheme.primarySeed.withAlpha(50),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                skills.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.tertiaryColor,
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              entry.value
                                  .map((skill) => ColorfulChip(label: skill))
                                  .toList(),
                        ),
                        SizedBox(height: 24),
                      ],
                    );
                  }).toList()
                  ..removeLast(),
          ),
        ),
      ],
    );
  }
}
