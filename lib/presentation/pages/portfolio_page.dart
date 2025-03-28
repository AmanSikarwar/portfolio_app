import 'package:flutter/material.dart';
import 'package:portfolio_app/widgets/about_section.dart';
import 'package:portfolio_app/widgets/contact_section.dart';
import 'package:portfolio_app/widgets/experience_section.dart';
import 'package:portfolio_app/widgets/home_section.dart';
import 'package:portfolio_app/widgets/projects_section.dart';
import 'package:provider/provider.dart';
import '../providers/scroll_provider.dart';
import '../widgets/navigation_bar.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollProvider = Provider.of<ScrollProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          CustomNavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HomeSection(key: scrollProvider.homeKey),
                  AboutSection(key: scrollProvider.aboutKey),
                  ExperienceSection(key: scrollProvider.experienceKey),
                  ProjectsSection(key: scrollProvider.projectsKey),
                  ContactSection(key: scrollProvider.contactKey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
