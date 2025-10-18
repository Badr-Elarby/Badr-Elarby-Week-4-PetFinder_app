import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:petfinder_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:petfinder_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:petfinder_app/features/home/presentation/screens/home_screen.dart';
import 'package:petfinder_app/features/home/presentation/cubits/home_cubit/home_cubit.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/screens/product_details_screen.dart';
import 'package:petfinder_app/features/ProductDetails/presentation/cubit/product_details_cubit.dart';
import 'package:petfinder_app/core/widgets/bottom_nav_bar.dart';

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

        // Shell Routes with Bottom Navigation
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              body: child,
              bottomNavigationBar: BottomNavBar(
                currentIndex: _getCurrentIndex(state.uri.toString()),
              ),
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              name: AppRoutes.home,
              builder: (context, state) => BlocProvider(
                create: (context) => GetIt.instance<HomeCubit>(),
                child: const HomeScreen(),
              ),
            ),
            GoRoute(
              path: '/favorites',
              name: AppRoutes.favorites,
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Favorites Screen - Coming Soon')),
              ),
            ),
            GoRoute(
              path: '/chat',
              name: AppRoutes.chat,
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Chat Screen - Coming Soon')),
              ),
            ),
            GoRoute(
              path: '/profile',
              name: AppRoutes.profile,
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Profile Screen - Coming Soon')),
              ),
            ),
            GoRoute(
              path: '/product-details/:id',
              name: AppRoutes.productDetails,
              builder: (context, state) => BlocProvider(
                create: (context) => GetIt.instance<ProductDetailsCubit>(),
                child: ProductDetailsScreen(catId: state.pathParameters['id']!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _getCurrentIndex(String path) {
    switch (path) {
      case '/home':
        return 0;
      case '/favorites':
        return 1;
      case '/chat':
        return 2;
      case '/profile':
        return 3;
      default:
        // For product details and other routes, maintain the home tab as active
        if (path.startsWith('/product-details/')) {
          return 0; // Keep home tab active when viewing product details
        }
        return 0;
    }
  }
}

// ---------------- ROUTE NAMES ----------------
class AppRoutes {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String productDetails = 'productDetails';
  static const String home = 'home';
  static const String favorites = 'favorites';
  static const String chat = 'chat';
  static const String profile = 'profile';
}
