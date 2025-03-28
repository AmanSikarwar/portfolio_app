# Aman Sikarwar Portfolio

[![Flutter](https://img.shields.io/badge/Flutter-3.29.2-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.0-0175C2?logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/amansikarwar/portfolio_app?style=social)](https://github.com/amansikarwar/portfolio_app)

A modern, responsive personal portfolio website built with Flutter web to showcase skills, projects, and experience. Featuring dynamic GitHub integration, smooth animations, and a polished dark theme UI.

![Portfolio Screenshot](assets/portfolio_screenshot.png)

## 🔗 Quick Links

- [Live Demo](https://amansikarwar.github.io) - See the portfolio in action
- [Features](#-features) - Discover what makes this portfolio special
- [Installation](#-installation) - Get started with development
- [Deployment](#-deployment) - Deploy your own version

## 🌟 Features

- **Responsive Design** - Seamlessly adapts to desktop, tablet, and mobile devices
- **Dark Theme** - Elegant dark mode interface with modern aesthetics and custom gradients
- **Animated Components** - Smooth animations and transitions for an engaging user experience
- **Dynamic GitHub Integration** - Automatically fetches and displays your latest GitHub projects with commit counts
- **Interactive Navigation** - Smooth scrolling navigation with highlighted sections
- **Contact Options** - Multiple methods for visitors to get in touch
- **Performance Optimized** - Fast loading times and efficient rendering for better UX

## 🚀 Sections

- **Home** - Welcoming introduction with animated role display and social links
- **About** - Personal bio, education details, and comprehensive skill showcase
- **Experience** - Interactive timeline-based display of work history and achievements
- **Projects** - Showcase of featured projects and dynamically loaded GitHub repositories
- **Contact** - Multiple contact options with interactive animations

## 🛠️ Technology Stack

### Front-End

- **Flutter Web** - Cross-platform UI framework for creating beautiful, natively compiled applications
- **Dart** - Scalable programming language optimized for building user interfaces
- **Custom Animations** - Hand-crafted animations using Flutter's animation framework
- **Responsive Layouts** - Custom responsive design system for all screen sizes

### State Management & Data

- **Provider** - Lightweight state management solution
- **HTTP** - For API requests to GitHub
- **JSON Serialization** - Custom serialization for GitHub API data

### Libraries & Utilities

- **Font Awesome** - Comprehensive icon library
- **URL Launcher** - For handling external links and emails
- **Flutter SVG** - SVG rendering for crisp graphics at any resolution

## 📋 Prerequisites

- Flutter SDK (Channel stable)
- Dart SDK (^3.29.2)
- A web browser

## 🔧 Installation

1. **Clone the repository**

```bash
git clone https://github.com/amansikarwar/portfolio_app.git
cd portfolio_app
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the application**

```bash
flutter run -d chrome
```

## 🧪 Development

For hot reload development experience:

```bash
flutter run -d chrome
```

To analyze the project:

```bash
flutter analyze
```

## 🚀 Deployment

### Deploying to GitHub Pages

1. Build the web version of the app:

```bash
flutter build web --release --base-href /portfolio_app/
```

2. Deploy the build artifacts to GitHub Pages:

```bash
# Create a gh-pages branch if not exists
git checkout -b gh-pages

# Clear branch except the build directory
git rm -rf .
git checkout HEAD -- build/web/

# Move the web build to root
mv build/web/* .
rm -rf build

# Add, commit and push
git add .
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages
```

### Deploying to a Custom Domain

1. Build the web version:

```bash
flutter build web --release
```

2. Configure DNS settings for your domain to point to your hosting provider

3. Deploy the contents of the `build/web` directory to your web hosting provider

4. For Netlify, Vercel, or similar platforms, you can set up continuous deployment from your GitHub repository

## 🤝 Contributing

Contributions are welcome! If you'd like to improve this project:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add some amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🗂️ Project Structure

```tree
lib/
├── core/
│   ├── providers/
│   │   └── theme_provider.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── models/
│   │   └── github_project.dart
│   └── services/
│       └── github_service.dart
├── presentation/
│   ├── pages/
│   │   └── portfolio_page.dart
│   ├── providers/
│   │   └── scroll_provider.dart
│   └── widgets/
│       └── navigation_bar.dart
├── widgets/
│   ├── about_section.dart
│   ├── contact_section.dart
│   ├── experience_section.dart
│   ├── home_section.dart
│   ├── projects_section.dart
│   ├── colorful_chip.dart
│   └── home/
│       ├── components/
│       │   ├── fading_roles.dart
│       │   ├── glowing_button.dart
│       │   ├── glowing_text.dart
│       │   ├── slide_in_text.dart
│       │   ├── social_link_bar.dart
│       │   └── tech_stack_icon.dart
│       └── index.dart
└── main.dart
```
