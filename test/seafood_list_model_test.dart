import 'package:flutter_test/flutter_test.dart';
import 'package:seafood_planner/models/seafood_list_model.dart';

void main() {
  test('reads image paths returned as image_path or image', () {
    final imagePathItem = SeafoodListModel.fromJson({
      'id': 1,
      'restaurant_id': 2,
      'title': 'Grilled salmon',
      'main_ingredient': 'Salmon',
      'notes': '',
      'image_path': 'storage/menus/salmon.jpg',
    });
    final imageItem = SeafoodListModel.fromJson({
      'id': 2,
      'restaurant_id': 2,
      'title': 'Shrimp soup',
      'main_ingredient': 'Shrimp',
      'notes': '',
      'image': '/storage/menus/shrimp.jpg',
    });

    expect(imagePathItem.imageUrl, 'storage/menus/salmon.jpg');
    expect(imageItem.imageUrl, '/storage/menus/shrimp.jpg');
  });
}
