import 'package:flutter/material.dart';

import '../models/meal_model.dart';
import '../models/restaurant_model.dart';
import '../services/crud_service.dart';
import '../theme/seafood_theme.dart';

class ExploreDetailPage extends StatelessWidget {
  final MealModel meal;
  const ExploreDetailPage({super.key, required this.meal});

  Future<void> _showSaveToCollectionDialog(BuildContext context) async {
    List<RestaurantModel> restaurants = [];
    try {
      restaurants = await CrudService.getRestaurants();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat kategori tempat')),
      );
      return;
    }

    if (!context.mounted) return;
    if (restaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Buat kategori Tempat dulu di tab Planner (misal: Masak Sendiri / Resto)',
          ),
        ),
      );
      return;
    }

    int selectedRestaurantId = restaurants.first.id;
    final notesCtrl = TextEditingController(
      text: 'Menu ${meal.strCategory} khas ${meal.strArea}',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Simpan ke Seafood Planner'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedRestaurantId,
                decoration: const InputDecoration(
                  labelText: 'Pilih Tempat (Masak Sendiri / Resto / Kafe)',
                  border: OutlineInputBorder(),
                ),
                items: restaurants
                    .map(
                      (r) => DropdownMenuItem(value: r.id, child: Text(r.name)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedRestaurantId = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catatan Rencana',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final mainIngredient = meal.ingredients.isNotEmpty
                    ? meal.ingredients.first
                    : 'Seafood';

                final success = await CrudService.saveSeafoodList(
                  restaurantId: selectedRestaurantId,
                  title: meal.strMeal,
                  mainIngredient: mainIngredient,
                  notes: notesCtrl.text,
                  imageUrl: meal.strMealThumb,
                );

                if (!context.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Berhasil disimpan ke Koleksi Seafood!'
                          : 'Gagal menyimpan menu',
                    ),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(meal.strMeal)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.network(
                  meal.strMealThumb,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 250,
                    child: ColoredBox(
                      color: SeafoodColors.paleMint,
                      child: Center(child: Icon(Icons.set_meal, size: 64)),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.strMeal,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category, size: 16),
                        label: Text(meal.strCategory),
                      ),
                      Chip(
                        avatar: const Icon(Icons.public, size: 16),
                        label: Text(meal.strArea),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showSaveToCollectionDialog(context),
                      icon: const Icon(Icons.bookmark_add),
                      label: const Text('Simpan ke Koleksi Saya'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SeafoodColors.deepGreen,
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Bahan Utama (1 - 5)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...meal.ingredients.map(
                    (ing) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: SeafoodColors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ing)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Cara Memasak / Instruksi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meal.strInstructions,
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
