import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/config/supabase_config.dart';
import '../presentation/widgets/session_config_widget.dart';
import 'widgets/admin_header.dart';
import 'widgets/personal_info_form.dart';
import 'widgets/experience_manager.dart';
import 'widgets/project_manager.dart';
import 'widgets/skill_manager.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabTitles = [
    'Personal Info',
    'Experiences',
    'Projects',
    'Skills',
  ];

  final List<IconData> _tabIcons = [
    Icons.person,
    Icons.work,
    Icons.code,
    Icons.star,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              AdminHeader(onBackPressed: () => Navigator.of(context).pop()),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    PersonalInfoForm(),
                    ExperienceManager(),
                    ProjectManager(),
                    SkillManager(),
                  ],
                ),
              ),
            ],
          ),
          // Session debug widget (positioned at bottom-right) - only in debug mode
          if (AppConfig.enableDebugMode)
            const Positioned(bottom: 0, right: 0, child: SessionConfigWidget()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colorScheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: List.generate(_tabTitles.length, (index) {
          return Tab(icon: Icon(_tabIcons[index]), text: _tabTitles[index]);
        }),
        labelColor: AppTheme.accentColor,
        unselectedLabelColor: Colors.white60,
        indicatorColor: AppTheme.accentColor,
        indicatorWeight: 3,
      ),
    );
  }
}
