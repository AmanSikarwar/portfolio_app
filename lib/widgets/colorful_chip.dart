import 'package:flutter/material.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';

class ColorfulChip extends StatelessWidget {
  final String label;

  const ColorfulChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _getColorForLabel(label);

    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: _getTextColor(color),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Color _getColorForLabel(String label) {
    int hash = 0;
    for (int i = 0; i < label.length; i++) {
      hash = label.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final Map<String, Color> predefinedColors = {
      'Flutter': AppTheme.primarySeed,
      'Dart': const Color(0xFF40C4FF),
      'Firebase': const Color(0xFFFFCA28),
      'React': const Color(0xFF61DAFB),
      'JavaScript': const Color(0xFFF7DF1E),
      'TypeScript': const Color(0xFF007ACC),
      'Python': const Color(0xFF3776AB),
      'AWS': const Color(0xFFFF9900),
      'Docker': Colors.blue[500]!,
      'Kubernetes': Colors.blue[600]!,
      'Git': Colors.red[400]!,
      'Node.js': Colors.green[600]!,
      'REST API': Colors.green[300]!,
      'SQL': Colors.amber[300]!,
      'NoSQL': Colors.purple[300]!,
      'MongoDB': Colors.green[500]!,
      'GraphQL': Colors.pink[400]!,
      'MQTT': Colors.teal[400]!,
      'BLE': Colors.indigo[400]!,
      'Rust': Colors.deepOrange[800]!,
      'Linux': Colors.grey[700]!,
      'Embedded': Colors.blueGrey[600]!,
      'Arduino': Colors.teal[600]!,
      'Raspberry Pi': Colors.red[700]!,
    };

    if (predefinedColors.containsKey(label)) {
      return predefinedColors[label]!;
    }

    return Color.fromARGB(
      255,
      100 + (hash & 0xFF) % 70,
      100 + ((hash >> 8) & 0xFF) % 70,
      120 + ((hash >> 16) & 0xFF) % 80,
    );
  }

  Color _getTextColor(Color backgroundColor) {
    double luminance =
        (0.299 * ((backgroundColor.r * 255.0).round() & 0xff) +
            0.587 * ((backgroundColor.g * 255.0).round() & 0xff) +
            0.114 * ((backgroundColor.b * 255.0).round() & 0xff)) /
        255;

    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
