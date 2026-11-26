class RestaurantModel {
  final int id;
  final String name;

  RestaurantModel({required this.id, required this.name});

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(id: json['id'], name: json['name'] ?? '');
  }
}
