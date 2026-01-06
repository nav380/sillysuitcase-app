import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userName;
  bool _isLoading = true;

  String? get token => _token;
  String? get userName => _userName;
  bool get isLoading => _isLoading;

  // 🔹 Load saved token + name on app start
  Future<void> loadToken() async {
    _isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    _userName = prefs.getString('user_name');
    _isLoading = false;
    notifyListeners();
  }

  // 🔹 Login
  Future<bool> login(String username, String password) async {
    final url = Uri.parse(
      'https://sillysuitcase.com/wp-json/simple-jwt-login/v1/auth',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'password': password.trim(),
        }),
      );

      final data = jsonDecode(response.body);

     if (data['success'] == true && data['data']['jwt'] != null) {
  _token = data['data']['jwt'];

  // ✅ USE INPUT USERNAME ONLY
  _userName = username.trim();

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token', _token!);
  await prefs.setString('user_name', _userName!);

  notifyListeners();
  return true;

      } else {
        debugPrint('Login failed: ${data['data']['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_name');

    _token = null;
    _userName = null;

    notifyListeners();
  }
}
