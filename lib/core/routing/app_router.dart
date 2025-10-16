import 'package:go_router/go_router.dart';
import 'package:petfinder_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:petfinder_app/features/onboarding/presentation/screens/onboarding_screen.dart';

class AppRouter {
  late GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: [
        // ---------------- SPLASH & ONBOARDING ----------------
        GoRoute(
          path: '/',
          name: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
      ],
    );
  }
}

// ---------------- ROUTE NAMES ----------------
class AppRoutes {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
}
