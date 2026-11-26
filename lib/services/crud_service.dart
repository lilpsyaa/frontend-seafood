import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../constants/api_constant.dart';
import '../models/restaurant_model.dart';
import '../models/seafood_list_model.dart';
import 'auth_service.dart';

class CrudService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  // ================= TABEL 1: RESTAURANTS =================
  static Future<List<RestaurantModel>> getRestaurants() async {
    final res = await http.get(
      Uri.parse(ApiConstant.restaurants),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body)['data'];
      return data.map((e) => RestaurantModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat kategori tempat');
  }

  static Future<bool> addRestaurant(String name) async {
    final res = await http.post(
      Uri.parse(ApiConstant.restaurants),
      headers: await _headers(),
      body: {'name': name},
    );
    return res.statusCode == 201;
  }

  static Future<bool> updateRestaurant(int id, String name) async {
    final res = await http.put(
      Uri.parse('${ApiConstant.restaurants}/$id'),
      headers: await _headers(),
      body: {'name': name},
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteRestaurant(int id) async {
    final res = await http.delete(
      Uri.parse('${ApiConstant.restaurants}/$id'),
      headers: await _headers(),
    );
    return res.statusCode == 200;
  }

  // ================= TABEL 2: SEAFOOD LISTS =================
  static Future<List<SeafoodListModel>> getSeafoodLists({
    int? restaurantId,
  }) async {
    String url = ApiConstant.seafoodLists;
    if (restaurantId != null) {
      url += '?restaurant_id=$restaurantId';
    }
    final res = await http.get(Uri.parse(url), headers: await _headers());
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body)['data'];
      return data.map((e) => SeafoodListModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat daftar menu seafood');
  }

  static Future<bool> saveSeafoodList({
    int? id,
    required int restaurantId,
    required String title,
    required String mainIngredient,
    required String notes,
    String? imageUrl,
    XFile? imageFile,
  }) async {
    final uri = id == null
        ? Uri.parse(ApiConstant.seafoodLists)
        : Uri.parse('${ApiConstant.seafoodLists}/$id');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _headers());

    if (id != null) {
      request.fields['_method'] = 'PUT';
    }
    request.fields['restaurant_id'] = restaurantId.toString();
    request.fields['title'] = title;
    request.fields['main_ingredient'] = mainIngredient;
    request.fields['notes'] = notes;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      request.fields['image_url'] = imageUrl;
    }

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image_file',
          bytes,
          filename: imageFile.name,
        ),
      );
    }

    final streamedResponse = await request.send();
    return streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201;
  }

  static Future<bool> deleteSeafoodList(int id) async {
    final res = await http.delete(
      Uri.parse('${ApiConstant.seafoodLists}/$id'),
      headers: await _headers(),
    );
    return res.statusCode == 200;
  }
}
