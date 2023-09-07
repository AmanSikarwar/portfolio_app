import 'package:flutter/material.dart';
import 'package:portfolio_app/src/constants.dart';
import 'package:portfolio_app/src/models/project_model.dart';
import 'package:portfolio_app/src/widgets/project.dart';

class PrijectSectionMobile extends StatelessWidget {
  const PrijectSectionMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Projects",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 16),
        for (Project project in projects)
          ProjectWidget(project: project),
      ],
    );
  }
}
