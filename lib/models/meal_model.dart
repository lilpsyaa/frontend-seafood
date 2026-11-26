class MealModel {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String strArea;
  final String strCategory;
  final List<String> ingredients;
  final String strInstructions;

  MealModel({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    required this.strArea,
    required this.strCategory,
    required this.ingredients,
    required this.strInstructions,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    List<String> extractedIngredients = [];
    for (int i = 1; i <= 5; i++) {
      final item = json['strIngredient$i'];
      if (item != null && item.toString().trim().isNotEmpty) {
        extractedIngredients.add(item.toString().trim());
      }
    }

    return MealModel(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strArea: json['strArea'] ?? 'Unknown',
      strCategory: json['strCategory'] ?? 'Seafood',
      ingredients: extractedIngredients,
      strInstructions: json['strInstructions'] ?? '',
    );
  }
}
