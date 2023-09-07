import 'package:flutter/material.dart';

class FooterSectionMobile extends StatelessWidget {
  const FooterSectionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "© 2023 - Built with Flutter",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            "Made with ❤️ by",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            "Aman Sikarwar",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
