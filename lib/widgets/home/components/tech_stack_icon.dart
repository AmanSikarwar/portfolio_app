import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';

class TechStackIcon {
  final String icon;
  final Offset position;
  final double size;
  Offset velocity;
  double opacity;
  final Offset initialPosition;
  final int seed;
  bool wasRepositioned = false;
  double fadeTransition = 1.0;

  TechStackIcon({
    required this.icon,
    required this.position,
    required this.size,
  }) : velocity = _generateRandomVelocity(),
       opacity = 0.5 + math.Random().nextDouble() * 0.3,
       initialPosition = position,
       seed = math.Random().nextInt(1000000);

  static Offset _generateRandomVelocity() {
    final angle = math.Random().nextDouble() * math.pi * 2;
    final speed = 0.0002 + math.Random().nextDouble() * 0.0003;
    return Offset(math.cos(angle) * speed, math.sin(angle) * speed);
  }

  IconData get iconData {
    switch (icon) {
      case 'flutter':
        return FontAwesomeIcons.flutter;
      case 'react':
        return FontAwesomeIcons.react;
      case 'python':
        return FontAwesomeIcons.python;
      case 'firebase':
        return FontAwesomeIcons.fire;
      case 'aws':
        return FontAwesomeIcons.aws;
      case 'js':
        return FontAwesomeIcons.js;
      case 'dart':
        return FontAwesomeIcons.dAndD;
      case 'database':
        return FontAwesomeIcons.database;
      case 'git':
        return FontAwesomeIcons.git;
      case 'node':
        return FontAwesomeIcons.nodeJs;
      case 'html':
        return FontAwesomeIcons.html5;
      case 'css':
        return FontAwesomeIcons.css3Alt;
      case 'docker':
        return FontAwesomeIcons.docker;
      case 'android':
        return FontAwesomeIcons.android;
      case 'apple':
        return FontAwesomeIcons.apple;
      case 'linux':
        return FontAwesomeIcons.linux;
      case 'cloud':
        return FontAwesomeIcons.cloud;
      case 'server':
        return FontAwesomeIcons.server;
      case 'code':
        return FontAwesomeIcons.code;
      case 'terminal':
        return FontAwesomeIcons.terminal;
      case 'brain':
        return FontAwesomeIcons.brain;
      case 'chart':
        return FontAwesomeIcons.chartSimple;
      case 'laptop':
        return FontAwesomeIcons.laptop;
      case 'mobile':
        return FontAwesomeIcons.mobileScreen;
      default:
        return FontAwesomeIcons.code;
    }
  }
}

class TechStackIconsPainter extends CustomPainter {
  final List<TechStackIcon> icons;
  final double animationValue;
  final bool isDarkMode;
  final Rect? contentSafeZone;
  final Map<int, Offset> _stablePositions = {};
  final double minIconDistance = 60.0;
  double _lastAnimationValue = 0.0;

  TechStackIconsPainter({
    required this.icons,
    required this.animationValue,
    required this.isDarkMode,
    this.contentSafeZone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bool isNewFrame = animationValue != _lastAnimationValue;
    _lastAnimationValue = animationValue;

    final List<Rect> safeAreas = [
      Rect.fromLTWH(0, 0, size.width, size.height * 0.1),
      Rect.fromLTWH(
        0,
        size.height * 0.75,
        size.width * 0.2,
        size.height * 0.25,
      ),
      Rect.fromLTWH(
        size.width * 0.8,
        size.height * 0.75,
        size.width * 0.2,
        size.height * 0.25,
      ),
      Rect.fromLTWH(0, 0, size.width * 0.1, size.height),
      Rect.fromLTWH(size.width * 0.9, 0, size.width * 0.1, size.height),
    ];

    if (contentSafeZone != null) {
      safeAreas.add(contentSafeZone!);
    }

    final List<Offset> currentPositions = [];
    final List<double> iconSizes = [];

    final List<Offset> initialPositions = [];
    for (var icon in icons) {
      final amplitude = size.height * 0.1;
      final frequency = 2 * math.pi / size.width;

      final xOffset = (animationValue * 40) * icon.velocity.dx;
      final yOffset =
          (animationValue * 40) * icon.velocity.dy +
          amplitude *
              math.sin(
                frequency *
                    (icon.position.dx * size.width + animationValue * 50),
              );

      Offset position;

      if (_stablePositions.containsKey(icon.seed)) {
        final stablePos = _stablePositions[icon.seed]!;
        position = Offset(
          (stablePos.dx + xOffset) % size.width,
          (stablePos.dy + yOffset) % size.height,
        );
      } else {
        position = Offset(
          (icon.initialPosition.dx * size.width + xOffset) % size.width,
          (icon.initialPosition.dy * size.height + yOffset) % size.height,
        );

        bool inSafeArea = false;
        for (var area in safeAreas) {
          if (area.contains(position)) {
            inSafeArea = true;
            break;
          }
        }

        if (!inSafeArea) {
          final random = math.Random(icon.seed);
          final selectedAreaIndex = random.nextInt(safeAreas.length);
          final selectedArea = safeAreas[selectedAreaIndex];
          final stableX =
              selectedArea.left + (selectedArea.width * random.nextDouble());
          final stableY =
              selectedArea.top + (selectedArea.height * random.nextDouble());
          _stablePositions[icon.seed] = Offset(stableX, stableY);
          final stablePosition = Offset(
            (stableX + xOffset) % size.width,
            (stableY + yOffset) % size.height,
          );

          position = stablePosition;
        }
      }

      initialPositions.add(position);
      iconSizes.add(icon.size * 0.8);
    }

    for (int i = 0; i < icons.length; i++) {
      var adjustedPosition = initialPositions[i];
      var needsRepositioning = false;

      for (int j = 0; j < currentPositions.length; j++) {
        final distance = (adjustedPosition - currentPositions[j]).distance;
        final minRequiredDistance = (iconSizes[i] + iconSizes[j]) / 2 + 20;

        if (distance < minRequiredDistance) {
          needsRepositioning = true;
          break;
        }
      }

      if (needsRepositioning && !icons[i].wasRepositioned && isNewFrame) {
        icons[i].wasRepositioned = true;
        icons[i].fadeTransition = 0.0;
      } else if (icons[i].wasRepositioned && icons[i].fadeTransition < 1.0) {
        icons[i].fadeTransition = math.min(1.0, icons[i].fadeTransition + 0.05);
      }

      if (needsRepositioning) {
        bool positionFound = false;
        for (int attempt = 0; attempt < 10; attempt++) {
          final angle =
              math.Random(icons[i].seed + attempt).nextDouble() * math.pi * 2;
          final distance =
              minIconDistance +
              math.Random(icons[i].seed + attempt).nextDouble() * 50;

          final newPosition = Offset(
            (initialPositions[i].dx + math.cos(angle) * distance) % size.width,
            (initialPositions[i].dy + math.sin(angle) * distance) % size.height,
          );

          bool validPosition = true;
          for (int j = 0; j < currentPositions.length; j++) {
            if ((newPosition - currentPositions[j]).distance <
                minIconDistance) {
              validPosition = false;
              break;
            }
          }

          if (validPosition) {
            adjustedPosition = newPosition;
            positionFound = true;
            break;
          }
        }

        if (!positionFound) {
          final edgeDistance = 20.0;
          adjustedPosition = Offset(
            edgeDistance +
                math.Random(icons[i].seed).nextDouble() *
                    (size.width - 2 * edgeDistance),
            edgeDistance +
                math.Random(icons[i].seed).nextDouble() *
                    (size.height - 2 * edgeDistance),
          );
        }

        _stablePositions[icons[i].seed] = adjustedPosition;
      }

      currentPositions.add(adjustedPosition);

      _drawIconWithFade(canvas, icons[i], adjustedPosition);
    }
  }

  void _drawIconWithFade(Canvas canvas, TechStackIcon icon, Offset position) {
    final effectiveOpacity = icon.opacity * 0.5 * icon.fadeTransition;

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.iconData.codePoint),
        style: TextStyle(
          fontFamily: icon.iconData.fontFamily,
          package: icon.iconData.fontPackage,
          fontSize: icon.size,
          color: AppTheme.colorScheme.onSurface.withAlpha(
            (effectiveOpacity * 255).toInt(),
          ),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(TechStackIconsPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
