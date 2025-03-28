import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final List<ContactMethod> _contactMethods = [
    ContactMethod(
      icon: FontAwesomeIcons.envelope,
      label: 'Email',
      value: 'amansikarwaar@gmail.com',
      action: () => launchUrl(Uri.parse('mailto:amansikarwaar@gmail.com')),
      color: const Color(0xFF64FFDA),
      actionText: 'Send Email',
    ),
    ContactMethod(
      icon: FontAwesomeIcons.phone,
      label: 'Mobile',
      value: '+91-97199-62248',
      action: () => launchUrl(Uri.parse('tel:+919719962248')),
      color: const Color(0xFFFF7597),
      actionText: 'Call Now',
    ),
    ContactMethod(
      icon: FontAwesomeIcons.linkedin,
      label: 'LinkedIn',
      value: 'linkedin.com/in/amansikarwar',
      action:
          () => launchUrl(Uri.parse('https://linkedin.com/in/amansikarwar')),
      color: const Color(0xFF0A66C2),
      actionText: 'Connect',
    ),
    ContactMethod(
      icon: FontAwesomeIcons.github,
      label: 'GitHub',
      value: 'github.com/amansikarwar',
      action: () => launchUrl(Uri.parse('https://github.com/amansikarwar')),
      color: const Color(0xFF6E5494),
      actionText: 'Follow',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withAlpha(130),
            colorScheme.surfaceContainerLowest.withAlpha(100),
            colorScheme.surface,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.2),
                end: Offset.zero,
              ).animate(_animationController),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback:
                          (bounds) => LinearGradient(
                            colors: [
                              AppTheme.accentColor,
                              AppTheme.tertiaryColor,
                              AppTheme.primarySeed,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                      child: Text(
                        'Get In Touch',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: 100,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentColor.withAlpha(100),
                            AppTheme.tertiaryColor.withAlpha(150),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: 600,
                      child: Text(
                        'I\'m always open to discussing new projects, creative ideas or opportunities to be part of your vision.',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final int gridColumns =
                    constraints.maxWidth > 1200
                        ? 4
                        : constraints.maxWidth > 800
                        ? 2
                        : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridColumns,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: _contactMethods.length,
                  itemBuilder: (context, index) {
                    return ContactCardAnimated(
                      contactMethod: _contactMethods[index],
                      index: index,
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 64),

          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - _animationController.value)),
                child: Opacity(
                  opacity: _animationController.value,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.accentColor.withAlpha(100),
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            color: AppTheme.accentColor.withAlpha(150),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            color: AppTheme.accentColor.withAlpha(200),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            color: AppTheme.accentColor.withAlpha(150),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            color: AppTheme.accentColor.withAlpha(100),
                            size: 12,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppTheme.accentColor.withAlpha(15),
                        ),
                        child: Text(
                          '© ${DateTime.now().year} Aman Sikarwar. Made with Flutter.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ContactMethod {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback action;
  final Color color;
  final String actionText;

  ContactMethod({
    required this.icon,
    required this.label,
    required this.value,
    required this.action,
    required this.color,
    required this.actionText,
  });
}

class ContactCardAnimated extends StatefulWidget {
  final ContactMethod contactMethod;
  final int index;

  const ContactCardAnimated({
    super.key,
    required this.contactMethod,
    required this.index,
  });

  @override
  State<ContactCardAnimated> createState() => _ContactCardAnimatedState();
}

class _ContactCardAnimatedState extends State<ContactCardAnimated>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isTapped = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _pressAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.1, curve: Curves.easeOut),
      ),
    );

    Future.delayed(Duration(milliseconds: 300 + widget.index * 150), () {
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
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isTapped ? _pressAnimation.value : _scaleAnimation.value,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _controller.value,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.contactMethod.action();
                },
                onTapDown: (_) => setState(() => _isTapped = true),
                onTapUp: (_) => setState(() => _isTapped = false),
                onTapCancel: () => setState(() => _isTapped = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuint,
                  transform:
                      Matrix4.identity()
                        ..translate(0, _isHovered || _isTapped ? -8.0 : 0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surfaceContainerHigh,
                        colorScheme.surfaceContainerLow,
                      ],
                    ),
                    boxShadow: [
                      if (_isHovered || _isTapped)
                        BoxShadow(
                          color: widget.contactMethod.color.withAlpha(
                            _isTapped ? 70 : 50,
                          ),
                          blurRadius: _isTapped ? 16 : 20,
                          spreadRadius: _isTapped ? 3 : 5,
                        ),
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color:
                          _isHovered || _isTapped
                              ? widget.contactMethod.color.withAlpha(
                                _isTapped ? 200 : 150,
                              )
                              : Colors.transparent,
                      width: _isTapped ? 2.5 : 2,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double iconSize = 80.0;
                        final double labelHeight = 24.0;
                        final double valueHeight = 44.0;
                        final double buttonHeight = 46.0;
                        final double spacing = 36.0;

                        final double availableHeight =
                            constraints.maxHeight -
                            (iconSize +
                                labelHeight +
                                valueHeight +
                                buttonHeight +
                                spacing);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: iconSize,
                              width: iconSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _isHovered
                                        ? widget.contactMethod.color.withAlpha(
                                          40,
                                        )
                                        : colorScheme.surfaceContainerHighest
                                            .withAlpha(100),
                                border: Border.all(
                                  color:
                                      _isHovered
                                          ? widget.contactMethod.color
                                          : widget.contactMethod.color
                                              .withAlpha(100),
                                  width: 2,
                                ),
                                boxShadow:
                                    _isHovered
                                        ? [
                                          BoxShadow(
                                            color: widget.contactMethod.color
                                                .withAlpha(60),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Center(
                                child: FaIcon(
                                  widget.contactMethod.icon,
                                  size: 32,
                                  color:
                                      _isHovered
                                          ? widget.contactMethod.color
                                          : widget.contactMethod.color
                                              .withAlpha(200),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.contactMethod.label,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Flexible(
                              child: Text(
                                widget.contactMethod.value,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withAlpha(180),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),

                            availableHeight > 0
                                ? SizedBox(height: availableHeight)
                                : const SizedBox(height: 16),

                            LayoutBuilder(
                              builder: (context, btnConstraints) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width:
                                      _isHovered || _isTapped
                                          ? btnConstraints.maxWidth
                                          : 160,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient:
                                        _isHovered || _isTapped
                                            ? LinearGradient(
                                              colors: [
                                                widget.contactMethod.color
                                                    .withAlpha(200),
                                                widget.contactMethod.color,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                            : null,
                                    color:
                                        _isHovered || _isTapped
                                            ? null
                                            : Colors.transparent,
                                    border: Border.all(
                                      color: widget.contactMethod.color,
                                      width: _isTapped ? 2.5 : 2,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: widget.contactMethod.action,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            _isHovered || _isTapped
                                                ? MainAxisAlignment.center
                                                : MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            _isHovered || _isTapped
                                                ? Icons.arrow_forward
                                                : Icons.touch_app,
                                            size: 16,
                                            color:
                                                _isHovered || _isTapped
                                                    ? Colors.white
                                                    : widget
                                                        .contactMethod
                                                        .color,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            widget.contactMethod.actionText,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color:
                                                  _isHovered || _isTapped
                                                      ? Colors.white
                                                      : widget
                                                          .contactMethod
                                                          .color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
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
        );
      },
    );
  }
}
