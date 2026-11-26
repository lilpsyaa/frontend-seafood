import 'restaurant_model.dart';

class SeafoodListModel {
  final int id;
  final int restaurantId;
  final String title;
  final String mainIngredient;
  final String notes;
  final String? imageUrl;
  final RestaurantModel? restaurant;

  SeafoodListModel({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.mainIngredient,
    required this.notes,
    this.imageUrl,
    this.restaurant,
  });

  factory SeafoodListModel.fromJson(Map<String, dynamic> json) {
    return SeafoodListModel(
      id: json['id'],
      restaurantId: int.parse(json['restaurant_id'].toString()),
      title: json['title'] ?? '',
      mainIngredient: json['main_ingredient'] ?? '',
      notes: json['notes'] ?? '',
      imageUrl: json['image_url'],
      restaurant: json['restaurant'] != null
          ? RestaurantModel.fromJson(json['restaurant'])
          : null,
    );
  }
}
