import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/scroll_provider.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final scrollProvider = Provider.of<ScrollProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isDesktop = screenWidth > 1024;
    final bool isTablet = screenWidth > 600 && screenWidth <= 1024;
    final bool isMobile = screenWidth <= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 8,
        vertical: isDesktop ? 16 : 12,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.homeGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isMobile
          ? _buildMobileNavBar(scrollProvider)
          : isTablet
          ? _buildTabletNavBar(scrollProvider)
          : _buildDesktopNavBar(scrollProvider),
    );
  }

  Widget _buildDesktopNavBar(ScrollProvider scrollProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: scrollProvider.sections.entries.map((entry) {
            return buildNavButton(
              context,
              entry.key,
              () => scrollProvider.scrollToSection(entry.value),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          }).toList(),
        ),
        _buildAdminButton(),
      ],
    );
  }

  Widget _buildTabletNavBar(ScrollProvider scrollProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: scrollProvider.sections.entries.map((entry) {
              return buildNavButton(
                context,
                entry.key,
                () => scrollProvider.scrollToSection(entry.value),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                fontSize: 14,
              );
            }).toList(),
          ),
        ),
        _buildAdminButton(isTablet: true),
      ],
    );
  }

  Widget _buildMobileNavBar(ScrollProvider scrollProvider) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: scrollProvider.sections.entries.map((entry) {
                return buildNavButton(
                  context,
                  entry.key,
                  () => scrollProvider.scrollToSection(entry.value),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  fontSize: 13,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildAdminButton(isMobile: true),
      ],
    );
  }

  Widget buildNavButton(
    BuildContext context,
    String label,
    VoidCallback onPressed, {
    bool isVertical = false,
    EdgeInsetsGeometry? padding,
    double? fontSize,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        splashColor: AppTheme.accentColor.withAlpha(50),
        highlightColor: AppTheme.accentColor.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              fontSize: fontSize ?? 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton({bool isTablet = false, bool isMobile = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/login');
        },
        splashColor: AppTheme.accentColor.withAlpha(50),
        highlightColor: AppTheme.accentColor.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : (isTablet ? 12 : 16),
            vertical: isMobile ? 4 : (isTablet ? 6 : 8),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.accentColor.withAlpha(100),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: isMobile ? 14 : (isTablet ? 16 : 18),
                color: AppTheme.accentColor,
              ),
              if (!isMobile) ...[
                const SizedBox(width: 4),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    fontSize: isMobile ? 12 : (isTablet ? 13 : 14),
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
