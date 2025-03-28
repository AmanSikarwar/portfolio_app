import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:portfolio_app/widgets/home/components/glowing_button.dart';
import 'package:portfolio_app/widgets/home/components/glowing_text.dart';
import 'package:portfolio_app/widgets/home/components/slide_in_text.dart';
import 'package:portfolio_app/widgets/home/components/social_link_bar.dart';
import 'package:portfolio_app/widgets/home/components/tech_stack_icon.dart';
import 'package:portfolio_app/widgets/home/components/fading_roles.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingIconsController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final List<TechStackIcon> _techIcons = [
    TechStackIcon(icon: 'flutter', position: const Offset(0.1, 0.2), size: 36),
    TechStackIcon(icon: 'react', position: const Offset(0.8, 0.3), size: 32),
    TechStackIcon(icon: 'python', position: const Offset(0.2, 0.7), size: 40),
    TechStackIcon(
      icon: 'firebase',
      position: const Offset(0.85, 0.6),
      size: 30,
    ),
    TechStackIcon(icon: 'aws', position: const Offset(0.6, 0.2), size: 34),
    TechStackIcon(icon: 'js', position: const Offset(0.5, 0.8), size: 28),
    TechStackIcon(icon: 'dart', position: const Offset(0.3, 0.4), size: 32),
    TechStackIcon(
      icon: 'database',
      position: const Offset(0.7, 0.75),
      size: 36,
    ),
    TechStackIcon(icon: 'git', position: const Offset(0.15, 0.85), size: 30),

    TechStackIcon(icon: 'node', position: const Offset(0.25, 0.15), size: 34),
    TechStackIcon(icon: 'html', position: const Offset(0.9, 0.45), size: 30),
    TechStackIcon(icon: 'css', position: const Offset(0.05, 0.55), size: 30),
    TechStackIcon(icon: 'docker', position: const Offset(0.75, 0.15), size: 36),
    TechStackIcon(icon: 'linux', position: const Offset(0.4, 0.65), size: 32),
    TechStackIcon(icon: 'cloud', position: const Offset(0.55, 0.35), size: 28),
    TechStackIcon(
      icon: 'terminal',
      position: const Offset(0.82, 0.9),
      size: 26,
    ),
    TechStackIcon(icon: 'brain', position: const Offset(0.3, 0.9), size: 30),
    TechStackIcon(icon: 'chart', position: const Offset(0.15, 0.35), size: 28),
    TechStackIcon(icon: 'mobile', position: const Offset(0.65, 0.55), size: 30),
  ];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _floatingIconsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(_pulseController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingIconsController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    final bool isDesktop = screenSize.width > 1024;

    return SizedBox(
      height: screenSize.height - MediaQuery.of(context).size.height * 0.05,
      width: screenSize.width,
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.homeGradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _floatingIconsController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: TechStackIconsPainter(
                      icons: _techIcons,
                      animationValue: _floatingIconsController.value,
                      isDarkMode: true,
                    ),
                  );
                },
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(77),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SizedBox(
                height:
                    screenSize.height - MediaQuery.of(context).padding.vertical,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildResponsiveContent(
                          isDesktop,
                          colorScheme,
                          screenSize,
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

  Widget _buildResponsiveContent(
    bool isDesktop,
    ColorScheme colorScheme,
    Size screenSize,
  ) {
    final bool isTablet = screenSize.width > 600 && screenSize.width <= 1024;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeText(colorScheme),
                  const SizedBox(height: 16),
                  _buildNameHeading(colorScheme),
                  const SizedBox(height: 16),
                  _buildRoleText(colorScheme),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      _buildResumeButton(colorScheme),
                      const SizedBox(width: 20),
                      Expanded(child: _buildSocialLinks()),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Center(child: _buildProfileIllustration(colorScheme)),
                );
              },
            ),
          ),
        ],
      );
    } else if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeText(colorScheme),
                  const SizedBox(height: 12),
                  _buildNameHeading(
                    colorScheme,
                    fontSize: 48,
                  ),
                  const SizedBox(height: 12),
                  _buildRoleText(
                    colorScheme,
                    fontSize: 20,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      _buildResumeButton(colorScheme),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSocialLinks()),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Center(
                    child: _buildProfileIllustration(colorScheme, size: 220),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              screenSize.height - MediaQuery.of(context).padding.vertical,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                _buildWelcomeText(colorScheme),
                const SizedBox(height: 12),
                _buildNameHeading(
                  colorScheme,
                  fontSize: 45,
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: _buildProfileIllustration(colorScheme, size: 200),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildRoleText(colorScheme),
                const SizedBox(height: 20),
                _buildResumeButton(colorScheme),
                const SizedBox(height: 20),
                _buildSocialLinks(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildWelcomeText(ColorScheme colorScheme) {
    return SlideInText(
      text: 'Hello, I\'m',
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppTheme.accentColor,
      ),
      delay: const Duration(milliseconds: 300),
    );
  }

  Widget _buildNameHeading(ColorScheme colorScheme, {double? fontSize}) {
    return GlowingText(
      text: 'Aman Sikarwar',
      textStyle: TextStyle(
        fontSize: fontSize ?? 60,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        height: 1.1,
      ),
      glowColor: AppTheme.primarySeed.withAlpha(
        179,
      ),
      textColor: Colors.white,
    );
  }

  Widget _buildRoleText(ColorScheme colorScheme, {double? fontSize}) {
    final List<String> roles = [
      'Software Developer',
      'Mobile App Developer',
      'Python Programmer',
      'Data Science Enthusiast',
      'Flutter Expert',
      'Web Developer',
    ];

    return FadingRoles(
      roles: roles,
      style: TextStyle(
        fontSize: fontSize ?? 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildResumeButton(ColorScheme colorScheme) {
    return GlowingButton(
      text: 'Download Resume',
      icon: Icons.download_rounded,
      onPressed: () => _downloadResume(),
      primaryColor: AppTheme.accentColor,
      textColor: AppTheme.colorScheme.surface,
    );
  }

  Future<void> _downloadResume() async {
    const String resumeUrl =
        'https://drive.google.com/uc?export=download&id=1_zo9UeF5xL92jeO3urnEOvCZxAdnJVei';
    if (await canLaunchUrl(Uri.parse(resumeUrl))) {
      await launchUrl(Uri.parse(resumeUrl));
    }
  }

  Widget _buildSocialLinks() {
    return const SocialLinkBar();
  }

  Widget _buildProfileIllustration(
    ColorScheme colorScheme, {
    double size = 280,
  }) {
    final accentColor = AppTheme.accentColor;
    final glowColor = AppTheme.accentColor.withAlpha(51);
    final backgroundColor = AppTheme.colorScheme.surface.withAlpha(77);
    final shadowColor = AppTheme.accentColor.withAlpha(38);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size + 40,
          height: size + 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [glowColor, Colors.transparent]),
          ),
        ),

        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: Border.all(color: accentColor.withAlpha(77), width: 2),
            boxShadow: [
              BoxShadow(color: shadowColor, blurRadius: 30, spreadRadius: 5),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/Aman Sikarwar.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
