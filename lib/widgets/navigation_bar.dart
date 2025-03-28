import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  final Function(GlobalKey) onTap;

  NavigationBar({super.key, required this.onTap});

  final List<Map<String, dynamic>> sections = [
    {'name': 'Home', 'key': GlobalKey()},
    {'name': 'About', 'key': GlobalKey()},
    {'name': 'Experience', 'key': GlobalKey()},
    {'name': 'Projects', 'key': GlobalKey()},
    {'name': 'Contact', 'key': GlobalKey()},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            sections.map((section) {
              return TextButton(
                onPressed: () => onTap(section['key'] as GlobalKey),
                child: Text(
                  section['name'] as String,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
      ),
    );
  }
}
