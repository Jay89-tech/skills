import 'package:flutter/material.dart';
import '../views/auth/splash_screen.dart';
import '../views/auth/onboarding_screen.dart';
import '../views/auth/auth_screen.dart';
import '../views/dashboard/dashboard_screen.dart';

class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case auth:
        return MaterialPageRoute(builder: (_) => AuthScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}