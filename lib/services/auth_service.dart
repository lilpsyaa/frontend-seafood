import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constant.dart';
import '../models/user_model.dart';

typedef AuthResult = Map<String, dynamic>;

class AuthService {
  static const Duration _requestTimeout = Duration(seconds: 15);

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<AuthResult> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstant.login),
            headers: {'Accept': 'application/json'},
            body: {'email': email, 'password': password},
          )
          .timeout(_requestTimeout);

      final data = _decodeResponse(response);
      if (response.statusCode == 200) {
        final token = data['token'] ?? data['access_token'];
        if (token is! String || token.isEmpty) {
          return {
            'success': false,
            'message': 'Server tidak mengirim token login.',
          };
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return {'success': true, 'message': data['message']?.toString()};
      }
      return {
        'success': false,
        'message': data['message']?.toString() ?? 'Login gagal',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Koneksi timeout. Pastikan server Laravel aktif.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstant.register),
            headers: {'Accept': 'application/json'},
            body: {'name': name, 'email': email, 'password': password},
          )
          .timeout(_requestTimeout);

      final data = _decodeResponse(response);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final token = data['token'] ?? data['access_token'];
        if (token is! String || token.isEmpty) {
          return {
            'success': false,
            'message': 'Server tidak mengirim token pendaftaran.',
          };
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return {'success': true, 'message': data['message']?.toString()};
      }
      return {
        'success': false,
        'message': data['message']?.toString() ?? 'Registrasi gagal',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Koneksi timeout. Pastikan server Laravel aktif.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  static AuthResult _decodeResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (body is AuthResult) return body;
    throw const FormatException('Respons server bukan objek JSON.');
  }

  static Future<UserModel?> getUserProfile() async {
    try {
      final token = await getToken();
      final response = await http
          .get(
            Uri.parse(ApiConstant.user),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      final token = await getToken();
      await http
          .post(
            Uri.parse(ApiConstant.logout),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_requestTimeout);
    } catch (_) {
      // Tetap hapus token lokal meskipun request ke server gagal
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
  }
}