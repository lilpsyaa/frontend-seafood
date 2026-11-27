import 'package:flutter/foundation.dart';

class ApiConstant {
  static String get baseUrlLaravel {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  static String? resolveImageUrl(String? imageUrl) {
    final value = imageUrl?.trim();
    if (value == null || value.isEmpty) return null;

    final imageUri = Uri.tryParse(value);
    if (imageUri == null) return null;

    final apiUri = Uri.parse(baseUrlLaravel);
    if (imageUri.hasScheme) {
      if (imageUri.host == 'localhost' || imageUri.host == '127.0.0.1') {
        return imageUri
            .replace(
              host: apiUri.host,
              port: imageUri.hasPort ? imageUri.port : apiUri.port,
            )
            .toString();
      }
      return imageUri.toString();
    }

    return apiUri.replace(path: '/').resolveUri(imageUri).toString();
  }

  static const String publicApiUrl =
      'https://www.themealdb.com/api/json/v1/1/search.php?s=fish';

  // Auth Endpoints
  static String get register => '$baseUrlLaravel/register';
  static String get login => '$baseUrlLaravel/login';
  static String get user => '$baseUrlLaravel/user';
  static String get logout => '$baseUrlLaravel/logout';

  // CRUD Endpoints
  static String get restaurants => '$baseUrlLaravel/restaurants';
  static String get seafoodLists => '$baseUrlLaravel/seafood-lists';
}
