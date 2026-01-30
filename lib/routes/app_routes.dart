import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_verification_screen.dart';
import '../features/main/main_app.dart';
import '../features/booking/book_pickup_screen.dart';
import '../features/report/report_issue_screen.dart';
import '../features/rewards/rewards_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otpVerification = '/otp-verification';
  static const mainApp = '/main';
  static const bookPickup = '/book-pickup';
  static const reportIssue = '/report-issue';
  static const rewards = '/rewards';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            verificationId: args['verificationId'],
            phoneNumber: args['phoneNumber'],
          ),
        );
      case mainApp:
        return MaterialPageRoute(builder: (_) => const MainApp());
      case bookPickup:
        return MaterialPageRoute(builder: (_) => const BookPickupScreen());
      case reportIssue:
        return MaterialPageRoute(builder: (_) => const ReportIssueScreen());
      case rewards:
        return MaterialPageRoute(builder: (_) => const RewardsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    mainApp: (_) => const MainApp(),
    bookPickup: (_) => const BookPickupScreen(),
    reportIssue: (_) => const ReportIssueScreen(),
    rewards: (_) => const RewardsScreen(),
  };
}
