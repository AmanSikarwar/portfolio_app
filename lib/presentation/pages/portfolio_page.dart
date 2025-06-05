import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio_app/widgets/about_section.dart';
import 'package:portfolio_app/widgets/contact_section.dart';
import 'package:portfolio_app/widgets/experience_section.dart';
import 'package:portfolio_app/widgets/home_section.dart';
import 'package:portfolio_app/widgets/projects_section.dart';
import 'package:provider/provider.dart';
import '../providers/scroll_provider.dart';
import '../widgets/navigation_bar.dart';
import '../../core/providers/portfolio_data_provider.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  bool _showAdminButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final portfolioProvider = Provider.of<PortfolioDataProvider>(
      context,
      listen: false,
    );
    try {
      await portfolioProvider.initialize();
    } catch (e) {
      debugPrint('Failed to initialize Supabase data, using fallback: $e');
      portfolioProvider.loadFallbackData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollProvider = Provider.of<ScrollProvider>(context);
    final portfolioProvider = Provider.of<PortfolioDataProvider>(context);

    if (portfolioProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: GestureDetector(
        onLongPress: () {
          setState(() {
            _showAdminButton = !_showAdminButton;
          });
        },
        child: Column(
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
      ),
      floatingActionButton: _showAdminButton
          ? FloatingActionButton(
              onPressed: () => context.go('/admin'),
              tooltip: 'Admin Dashboard',
              child: const Icon(Icons.admin_panel_settings),
            )
          : null,
    );
  }
}
