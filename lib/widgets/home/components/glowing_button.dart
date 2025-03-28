import 'package:flutter/material.dart';

class GlowingButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color textColor;

  const GlowingButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _pressAnimController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressAnimController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _pressAnimController.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _pressAnimController.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _pressAnimController.reverse();
        },
        child: AnimatedBuilder(
          animation: _pressAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pressAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      _isHovered || _isPressed
                          ? widget.primaryColor
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: widget.primaryColor, width: 2),
                  boxShadow:
                      _isHovered || _isPressed
                          ? [
                            BoxShadow(
                              color: widget.primaryColor.withAlpha(
                                _isPressed ? 150 : 128,
                              ),
                              blurRadius: _isPressed ? 4 : 8,
                              spreadRadius: _isPressed ? 0 : 1,
                            ),
                          ]
                          : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          color:
                              _isHovered || _isPressed
                                  ? widget.textColor
                                  : widget.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.text,
                          style: TextStyle(
                            color:
                                _isHovered || _isPressed
                                    ? widget.textColor
                                    : widget.primaryColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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
