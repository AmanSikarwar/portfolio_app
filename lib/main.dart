import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio_app/src/constants.dart';
import 'package:portfolio_app/src/footer_section.dart';
import 'package:portfolio_app/src/header_section.dart';
import 'package:portfolio_app/src/project_section.dart';
import 'package:portfolio_app/src/widgets/social_icons_tray.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:responsive_builder/responsive_builder.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Aman Sikarwar | Portfolio",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const PortfolioHome(),
    );
  }
}

class PortfolioHome extends StatelessWidget {
  const PortfolioHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aman Sikarwar | Portfolio"),
        backgroundColor: Colors.transparent,
        centerTitle: getDeviceType(MediaQuery.sizeOf(context)) ==
            DeviceScreenType.mobile,
        actions: [
          if (getDeviceType(MediaQuery.sizeOf(context)) ==
                  DeviceScreenType.desktop ||
              getDeviceType(MediaQuery.sizeOf(context)) ==
                  DeviceScreenType.tablet) ...[
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.github),
              onPressed: () => launchUrl(Uri.parse(githubUrl)),
              tooltip: "Github",
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.linkedin),
              onPressed: () => launchUrl(Uri.parse(linkedinUrl)),
              tooltip: "LinkedIn",
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.twitter),
              onPressed: () => launchUrl(Uri.parse(twitterUrl)),
              tooltip: "Twitter",
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.instagram),
              onPressed: () => launchUrl(Uri.parse(instagramUrl)),
              tooltip: "Instagram",
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.envelope),
              onPressed: () => launchUrl(Uri.parse(emailUrl)),
              tooltip: "Email",
            ),
          ]
        ],
      ),
      body: ResponsiveBuilder(builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType ==
            DeviceScreenType.desktop) {
          return const PortfolioHomeBodyDesktop();
        } else {
          return const PortfolioHomeBodyMobile();
        }
      }),
    );
  }
}

class PortfolioHomeBodyDesktop extends StatelessWidget {
  const PortfolioHomeBodyDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        HeaderSectionDesktop(),
        SizedBox(height: 16),
        Center(
          child: Text(
            "Work in Progress, switch to mobile view for now.",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
        // PrijectSectionDesktop(),
        // SizedBox(height: 16),
        // SocialIconsTray(),
        // SizedBox(height: 16),
        // FooterSectionDesktop()
      ],
    );
  }
}

class PortfolioHomeBodyMobile extends StatelessWidget {
  const PortfolioHomeBodyMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        HeaderSectionMobile(),
        SizedBox(height: 16),
        PrijectSectionMobile(),
        SizedBox(height: 16),
        SocialIconsTray(),
        SizedBox(height: 16),
        FooterSectionMobile()
      ],
    );
  }
}
