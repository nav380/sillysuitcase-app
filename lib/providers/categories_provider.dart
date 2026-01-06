import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoriesProvider extends ChangeNotifier {
  List categories = [];
  bool isLoading = false;

  Future<void> fetchCategories() async {
    if (isLoading || categories.isNotEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://sillysuitcase.com/wp-json/wp/v2/categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        categories = data ?? [];
        categories.sort(
            (a, b) => a['name'].toString().compareTo(b['name'].toString()));
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
