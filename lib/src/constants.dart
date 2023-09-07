import 'package:portfolio_app/src/models/project_model.dart';

const String githubUrl = 'https://github.com/AmanSikarwar';
const String linkedinUrl = 'https://www.linkedin.com/in/amansikarwaar/';
const String twitterUrl = 'https://twitter.com/AmanSikarwaar';
const String mediumUrl = 'https://medium.com/@amansikarwar';
const String instagramUrl = 'https://www.instagram.com/amansikarwaar/';
const String emailUrl = 'mailto:amansikarwaar@gmail.com';

// Projects

const projects = [
  moodleAPI,
  autoProxy,
  whatSaver,
];

const Project moodleAPI = Project(
  title: "Moodle API",
  description:
      "A dart client for the Moodle API. It is a wrapper around the Moodle API to make it easier to use.",
  projectUrl: "$githubUrl/moodle_api",
  tags: ["Dart", "Moodle", "API"],
  techStack: ["Dart"],
);

const Project autoProxy = Project(
  title: "Auto Proxy",
  description:
      "A rust based CLI tool to automatically switch proxy settings based on the network you are connected to.",
  projectUrl: "$githubUrl/auto_proxy",
  tags: ["Rust", "CLI"],
  techStack: ["Rust"],
);

const Project whatSaver = Project(
  title: "WhatSaver",
  description: "A flutter based mobile app to save WhatsApp statuses.",
  projectUrl: "$githubUrl/whatsaver",
  tags: ["Flutter", "WhatsApp", "API"],
  techStack: ["Flutter"],
);
