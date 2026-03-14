import 'package:flutter/material.dart';
import '../core/theme/app_gradients.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_verification_screen.dart';
import '../features/main/main_app.dart';
import '../features/booking/book_pickup_screen.dart';
import '../features/report/report_issue_screen.dart';
import '../features/rewards/rewards_screen.dart';
import '../features/statistics/statistics_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otpVerification = '/otp-verification';
  static const mainApp = '/main';
  static const bookPickup = '/book-pickup';
  static const reportIssue = '/report-issue';
  static const rewards = '/rewards';
  static const statistics = '/statistics';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          OTPVerificationScreen(
            verificationId: args['verificationId'],
            phoneNumber: args['phoneNumber'],
          ),
          settings,
        );
      case mainApp:
        return _buildRoute(const MainApp(), settings);
      case bookPickup:
        return _buildRoute(const BookPickupScreen(), settings);
      case reportIssue:
        return _buildRoute(const ReportIssueScreen(), settings);
      case rewards:
        return _buildRoute(const RewardsScreen(), settings);
      case statistics:
        return _buildRoute(const StatisticsScreen(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: const Color(0xFF0A0A0A),
            body: Center(
              child: Text(
                'No route defined for ${settings.name}',
                style: const TextStyle(color: Color(0xFFF5F5F5)),
              ),
            ),
          ),
        );
    }
  }

  // Custom page transition: slide from right, 280ms, easeOutCubic
  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => Container(
        decoration: const BoxDecoration(gradient: AppGradients.screenBg),
        child: page,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideIn = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final scaleOut = Tween<double>(begin: 1.0, end: 0.96).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic),
        );

        final fadeOut = Tween<double>(begin: 1.0, end: 0.6).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic),
        );

        return SlideTransition(
          position: slideIn,
          child: ScaleTransition(
            scale: scaleOut,
            child: FadeTransition(
              opacity: fadeOut,
              child: child,
            ),
          ),
        );
      },
    );
  }

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    mainApp: (_) => const MainApp(),
    bookPickup: (_) => const BookPickupScreen(),
    reportIssue: (_) => const ReportIssueScreen(),
    rewards: (_) => const RewardsScreen(),
    statistics: (_) => const StatisticsScreen(),
  };
}
