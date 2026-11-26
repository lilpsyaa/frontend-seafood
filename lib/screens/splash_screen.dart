import 'package:flutter/material.dart';

import '../routes/app_routing.dart';
import '../services/auth_service.dart';
import '../theme/seafood_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await AuthService.getToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRouting.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRouting.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SeafoodColors.green, SeafoodColors.lime],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.set_meal, size: 84, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'SEAFOOD PLANNER',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Rencanakan menu favoritmu',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: SeafoodColors.deepGreen),
            ],
          ),
        ),
      ),
    );
  }
}
