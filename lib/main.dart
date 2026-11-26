import 'package:flutter/material.dart';

import 'routes/app_routing.dart';
import 'theme/seafood_theme.dart';

void main() {
  runApp(const SeafoodPlannerApp());
}

class SeafoodPlannerApp extends StatelessWidget {
  const SeafoodPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seafood Planner',
      debugShowCheckedModeBanner: false,
      theme: buildSeafoodTheme(),
      initialRoute: AppRouting.splash,
      onGenerateRoute: AppRouting.onGenerateRoute,
    );
  }
}
