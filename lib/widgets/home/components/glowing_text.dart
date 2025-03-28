import 'package:flutter/material.dart';

class GlowingText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Color glowColor;
  final Color textColor;

  const GlowingText({
    super.key,
    required this.text,
    required this.textStyle,
    required this.glowColor,
    required this.textColor,
  });

  @override
  State<GlowingText> createState() => _GlowingTextState();
}

class _GlowingTextState extends State<GlowingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [widget.textColor, widget.glowColor, widget.textColor],
              stops: [0.0, _controller.value, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: widget.textStyle,
          ),
        );
      },
    );
  }
}
