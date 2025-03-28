import 'package:flutter/material.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class FadingRoles extends StatelessWidget {
  final List<String> roles;
  final TextStyle? style;
  final Duration pauseDuration;
  final Duration fadeDuration;

  const FadingRoles({
    super.key,
    required this.roles,
    this.style,
    this.pauseDuration = const Duration(seconds: 3),
    this.fadeDuration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Color> gradient = [
      AppTheme.accentColor,
      AppTheme.primarySeed,
      AppTheme.tertiaryColor,
    ];

    final defaultStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      shadows: [
        Shadow(
          color: Colors.black.withAlpha(153),
          blurRadius: 4,
          offset: const Offset(1, 1),
        ),
      ],
    );

    final textStyle = style ?? defaultStyle;

    String longestRole = '';
    for (final role in roles) {
      if (role.length > longestRole.length) {
        longestRole = role;
      }
    }

    final textSize = _calculateTextSize(longestRole, textStyle);
    final height = textSize.height + 4.0;

    return SizedBox(
      height: height,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback:
            (bounds) => LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
        child: AnimatedTextKit(
          animatedTexts:
              roles.map((role) {
                return FadeAnimatedText(
                  role,
                  textStyle: textStyle,
                  textAlign: TextAlign.center,
                  duration: pauseDuration + fadeDuration * 2,
                  fadeInEnd: 0.2,
                  fadeOutBegin: 0.8,
                );
              }).toList(),
          repeatForever: true,
          pause: const Duration(
            milliseconds: 100,
          ),
          displayFullTextOnTap: true,
          onTap: () {
          },
        ),
      ),
    );
  }

  Size _calculateTextSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size;
  }
}
