import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/portfolio_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/widgets/auth_guard.dart';
import '../../admin/admin_dashboard.dart';

class AppRouter {
  static const String home = '/';
  static const String admin = '/admin';
  static const String login = '/login';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const PortfolioPage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: admin,
        name: 'admin',
        builder: (context, state) => const AuthGuard(child: AdminDashboard()),
      ),
    ],
    errorBuilder: (context, state) => const _ErrorPage(),
  );
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
