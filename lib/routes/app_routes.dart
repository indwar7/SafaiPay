import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/user/dashboard/user_dashboard_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    dashboard: (_) => const UserDashboardScreen(),
  };
}
