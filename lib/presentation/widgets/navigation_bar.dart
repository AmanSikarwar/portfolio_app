import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      child:
          isMobile
              ? _buildMobileNavBar(scrollProvider)
              : isTablet
              ? _buildTabletNavBar(scrollProvider)
              : _buildDesktopNavBar(scrollProvider),
    );
  }

  Widget _buildDesktopNavBar(ScrollProvider scrollProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          scrollProvider.sections.entries.map((entry) {
            return buildNavButton(
              context,
              entry.key,
              () => scrollProvider.scrollToSection(entry.value),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          }).toList(),
    );
  }

  Widget _buildTabletNavBar(ScrollProvider scrollProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          scrollProvider.sections.entries.map((entry) {
            return buildNavButton(
              context,
              entry.key,
              () => scrollProvider.scrollToSection(entry.value),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              fontSize: 14,
            );
          }).toList(),
    );
  }

  Widget _buildMobileNavBar(ScrollProvider scrollProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            scrollProvider.sections.entries.map((entry) {
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
}
