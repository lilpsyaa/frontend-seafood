import 'package:flutter/material.dart';

import '../models/meal_model.dart';
import '../routes/app_routing.dart';
import '../services/public_api_service.dart';
import '../theme/seafood_theme.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late Future<List<MealModel>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _mealsFuture = PublicApiService.fetchSeafoodMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant, color: SeafoodColors.green, size: 22),
            SizedBox(width: 8),
            Text('SEAFOOD PLANNER'),
          ],
        ),
      ),
      body: FutureBuilder<List<MealModel>>(
        future: _mealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _mealsFuture = PublicApiService.fetchSeafoodMeals();
                    }),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final meals = snapshot.data ?? [];
          if (meals.isEmpty) {
            return const Center(child: Text('Tidak ada menu ditemukan'));
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            itemCount: meals.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  height: 310,
                  margin: const EdgeInsets.only(bottom: 18),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF079B35), Color(0xFF7BD20D)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 18,
                        left: 20,
                        child: Text(
                          'FRESH',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.1),
                            fontSize: 64,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -3,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -12,
                        top: 55,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(110),
                          child: Image.network(
                            meals.first.strMealThumb,
                            width: 220,
                            height: 175,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.set_meal,
                              size: 180,
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'SEAFOOD PLANNER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 26),
                            const Text(
                              'FRESH FROM\nTHE SEA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                height: 0.98,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                14,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(22),
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Menu seafood pilihan, inspirasi tanpa batas.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: SeafoodColors.ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Jelajahi resep dan susun menu favoritmu.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: SeafoodColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              final meal = meals[index - 1];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouting.exploreDetail,
                    arguments: meal,
                  ),
                  child: Row(
                    children: [
                      Image.network(
                        meal.strMealThumb,
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(
                          width: 112,
                          height: 112,
                          child: ColoredBox(
                            color: SeafoodColors.paleMint,
                            child: Icon(Icons.set_meal, size: 36),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal.strMeal,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.public,
                                    size: 16,
                                    color: SeafoodColors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Asal: ${meal.strArea}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
