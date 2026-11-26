import 'package:flutter/material.dart';

import '../models/meal_model.dart';
import '../screens/splash_screen.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';
import '../screens/main_page.dart';
import '../screens/explore_detail_page.dart';

class AppRouting {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String exploreDetail = '/explore-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case main:
        return MaterialPageRoute(builder: (_) => const MainPage());
      case exploreDetail:
        final meal = settings.arguments as MealModel;
        return MaterialPageRoute(builder: (_) => ExploreDetailPage(meal: meal));
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')),
          ),
        );
    }
  }
}
