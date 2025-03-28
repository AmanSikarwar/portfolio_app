import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageHelper {
  static bool isSvg(String path) {
    return path.toLowerCase().endsWith('.svg');
  }

  static Widget getImage({
    required String path,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Color? color,
  }) {
    if (isSvg(path)) {
      if (path.startsWith('http')) {
        return SvgPicture.network(
          path,
          fit: fit,
          width: width,
          height: height,
          colorFilter:
              color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
          placeholderBuilder:
              (context) => Container(
                width: width,
                height: height,
                color: Colors.grey[800],
                child: const Center(child: CircularProgressIndicator()),
              ),
        );
      } else {
        return SvgPicture.asset(
          path,
          fit: fit,
          width: width,
          height: height,
          colorFilter:
              color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        );
      }
    } else {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: fit,
          width: width,
          height: height,
          color: color,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: Colors.grey[800],
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[900],
              child: const Icon(Icons.broken_image, color: Colors.white60),
            );
          },
        );
      } else {
        return Image.asset(
          path,
          fit: fit,
          width: width,
          height: height,
          color: color,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[900],
              child: const Icon(Icons.broken_image, color: Colors.white60),
            );
          },
        );
      }
    }
  }
}
