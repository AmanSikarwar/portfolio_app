import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:portfolio_app/src/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialIconsTray extends StatelessWidget {
  const SocialIconsTray({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.github),
            onPressed: () => launchUrl(Uri.parse(githubUrl)),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.linkedin),
            onPressed: () => launchUrl(Uri.parse(linkedinUrl)),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.twitter),
            onPressed: () => launchUrl(Uri.parse(twitterUrl)),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.instagram),
            onPressed: () => launchUrl(Uri.parse(instagramUrl)),
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.envelope),
            onPressed: () => launchUrl(Uri.parse(emailUrl)),
          ),
        ],
      ),
    );
  }
}
