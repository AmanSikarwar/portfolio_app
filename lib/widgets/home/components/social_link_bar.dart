import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialLinkBar extends StatefulWidget {
  const SocialLinkBar({super.key});

  @override
  State<SocialLinkBar> createState() => _SocialLinkBarState();
}

class _SocialLinkBarState extends State<SocialLinkBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Animation<double>> _animations = [];

  final List<Map<String, dynamic>> _socialLinks = [
    {
      'icon': FontAwesomeIcons.github,
      'url': 'https://github.com/amansikarwar',
      'tooltip': 'GitHub',
    },
    {
      'icon': FontAwesomeIcons.linkedin,
      'url': 'https://linkedin.com/in/amansikarwar',
      'tooltip': 'LinkedIn',
    },
    {
      'icon': FontAwesomeIcons.instagram,
      'url': 'https://instagram.com/amansikarwaar',
      'tooltip': 'Instagram',
    },
    {
      'icon': FontAwesomeIcons.medium,
      'url': 'https://medium.com/@amansikarwar',
      'tooltip': 'Medium',
    },
    {
      'icon': FontAwesomeIcons.envelope,
      'url': 'mailto:amansikarwaar@gmail.com',
      'tooltip': 'Email',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    for (int i = 0; i < _socialLinks.length; i++) {
      final delay = i * 0.1;
      _animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(delay, delay + 0.4, curve: Curves.elasticOut),
          ),
        ),
      );
    }

    Future.delayed(const Duration(milliseconds: 800), () {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Wrap(
          spacing: isTablet ? 8 : 16,
          runSpacing: 12,
          children: List.generate(
            _socialLinks.length,
            (index) => _buildSocialIcon(
              _socialLinks[index],
              _animations[index].value,
              isTablet,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialIcon(
    Map<String, dynamic> link,
    double animValue,
    bool isTablet,
  ) {
    return Transform.scale(
      scale: animValue,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - animValue)),
        child: SocialIconButton(
          icon: link['icon'],
          tooltip: link['tooltip'],
          url: link['url'],
          size: isTablet ? 36 : 42,
        ),
      ),
    );
  }
}

class SocialIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final String url;
  final double size;

  const SocialIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.url,
    this.size = 42,
  });

  @override
  State<SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<SocialIconButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isTapped = false;
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _tapAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = AppTheme.accentColor;
    final Color hoverBgColor = iconColor.withAlpha(25);
    final Color borderColor =
        (_isHovered || _isTapped) ? iconColor : iconColor.withAlpha(128);

    final iconSize = widget.size * 0.48;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          launchUrl(Uri.parse(widget.url));
        },
        onTapDown: (_) {
          setState(() => _isTapped = true);
          _tapController.forward();
        },
        onTapUp: (_) {
          setState(() => _isTapped = false);
          _tapController.reverse();
        },
        onTapCancel: () {
          setState(() => _isTapped = false);
          _tapController.reverse();
        },
        child: AnimatedBuilder(
          animation: _tapAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _tapAnimation.value,
              child: Tooltip(
                message: widget.tooltip,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: widget.size,
                  width: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        (_isHovered || _isTapped)
                            ? hoverBgColor
                            : Colors.transparent,
                    border: Border.all(
                      color: borderColor,
                      width: _isTapped ? 2.5 : 2,
                    ),
                    boxShadow:
                        _isTapped
                            ? [
                              BoxShadow(
                                color: iconColor.withAlpha(40),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                            : null,
                  ),
                  child: Center(
                    child: FaIcon(
                      widget.icon,
                      color: iconColor,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
