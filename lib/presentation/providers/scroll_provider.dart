import 'package:flutter/material.dart';

class ScrollProvider extends ChangeNotifier {
  final GlobalKey homeKey = GlobalKey();
  final GlobalKey aboutKey = GlobalKey();
  final GlobalKey experienceKey = GlobalKey();
  final GlobalKey projectsKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  Map<String, GlobalKey> get sections => {
    'Home': homeKey,
    'About': aboutKey,
    'Experience': experienceKey,
    'Projects': projectsKey,
    'Contact': contactKey,
  };
}
