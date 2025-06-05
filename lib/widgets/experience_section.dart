import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';
import 'package:portfolio_app/widgets/colorful_chip.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_app/core/providers/portfolio_data_provider.dart';
import 'package:portfolio_app/data/models/experience.dart';

class ExperienceSection extends StatefulWidget {
  const ExperienceSection({super.key});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width <= 600;
    final portfolioProvider = Provider.of<PortfolioDataProvider>(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.surfaceContainerHighest, colorScheme.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Experience',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [AppTheme.accentColor, AppTheme.primarySeed],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (portfolioProvider.experiences.isEmpty)
            const Center(child: Text('No experiences available'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: portfolioProvider.experiences.length,
              itemBuilder: (context, index) {
                final experience = portfolioProvider.experiences[index];
                final isLast =
                    index == portfolioProvider.experiences.length - 1;

                return TimelineExperienceCard(
                  experience: _convertExperienceToMap(experience),
                  isLast: isLast,
                  index: index,
                );
              },
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> _convertExperienceToMap(Experience experience) {
    return {
      'company': experience.company,
      'role': experience.role,
      'duration': experience.duration,
      'icon': Icons.computer_outlined, // Default icon
      'color': _parseColor(experience.iconColor ?? '#64FFDA'),
      'skills': experience.skills,
      'description': experience.responsibilities,
    };
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF64FFDA); // Default color
    }
  }
}

class TimelineExperienceCard extends StatefulWidget {
  final Map<String, dynamic> experience;
  final bool isLast;
  final int index;

  const TimelineExperienceCard({
    super.key,
    required this.experience,
    required this.isLast,
    required this.index,
  });

  @override
  State<TimelineExperienceCard> createState() => _TimelineExperienceCardState();
}

class _TimelineExperienceCardState extends State<TimelineExperienceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
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
    final colorScheme = Theme.of(context).colorScheme;
    final companyColor = widget.experience['color'] as Color;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isMobile ? 30 : 40,
              child: Column(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: companyColor.withAlpha(50),
                      border: Border.all(color: companyColor, width: 2),
                    ),
                    child: Icon(
                      widget.experience['icon'] as IconData,
                      color: companyColor,
                      size: 18,
                    ),
                  ),
                  if (!widget.isLast)
                    Container(
                      width: 2,
                      height: 120,
                      color: colorScheme.surfaceContainerHighest,
                    ),
                ],
              ),
            ),

            SizedBox(width: isMobile ? 12 : 20),

            Expanded(
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isTapped = true),
                onTapUp: (_) => setState(() => _isTapped = false),
                onTapCancel: () => setState(() => _isTapped = false),
                onTap: () => HapticFeedback.selectionClick(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..translate(0, _isTapped ? 1.0 : 0.0),
                  child: Card(
                    elevation: _isTapped ? 6 : 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: companyColor.withAlpha(_isTapped ? 80 : 50),
                        width: _isTapped ? 1.5 : 1,
                      ),
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        splashColor: companyColor.withAlpha(20),
                        highlightColor: companyColor.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.surfaceContainerHigh,
                                colorScheme.surfaceContainerLow,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 12 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.experience['company'],
                                  style: TextStyle(
                                    color: companyColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.experience['role'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.experience['duration'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      (widget.experience['skills'] as List)
                                          .map(
                                            (skill) =>
                                                ColorfulChip(label: skill),
                                          )
                                          .toList(),
                                ),

                                const SizedBox(height: 16),

                                ...((widget.experience['description'] as List)
                                    .map((desc) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.arrow_right_rounded,
                                              color: companyColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                desc,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                    .toList()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
