import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constant.dart';
import '../models/meal_model.dart';

class PublicApiService {
  static Future<List<MealModel>> fetchSeafoodMeals() async {
    final response = await http.get(Uri.parse(ApiConstant.publicApiUrl));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List meals = body['meals'] ?? [];
      return meals.map((e) => MealModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data dari TheMealDB');
    }
  }
}
