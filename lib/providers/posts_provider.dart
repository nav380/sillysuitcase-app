import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostsProvider extends ChangeNotifier {
  List posts = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  // For search
  bool isSearching = false;
  String? searchQuery;
  int? categoryId;

  // Fetch posts (normal or category)
  Future<void> fetchPosts({String? token, int? categoryId}) async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();

    this.categoryId = categoryId;

    final url = Uri.parse(
        'https://sillysuitcase.com/wp-json/wp/v2/posts?page=$page&per_page=5&_embed${categoryId != null ? "&categories=$categoryId" : ""}');

    try {
      final response = await http.get(
        url,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isEmpty || page > 5) {
          hasMore = false;
        } else {
          posts.addAll(data);
          page++;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  // --- Search ---
  Future<void> searchPosts({required String query}) async {
    isSearching = true;
    searchQuery = query;
    page = 1;
    posts.clear();
    hasMore = true;
    notifyListeners();

    final url = Uri.parse(
        'https://sillysuitcase.com/wp-json/wp/v2/posts?search=$query&per_page=5&_embed${categoryId != null ? "&categories=$categoryId" : ""}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        posts.addAll(data);
        if (data.isEmpty) hasMore = false;
        page++;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  void resetSearch() {
    isSearching = false;
    searchQuery = null;
    page = 1;
    posts.clear();
    hasMore = true;
    notifyListeners();
  }

  Future<Map> fetchSinglePost(int id) async {
    try {
      final response = await http.get(
        Uri.parse('https://sillysuitcase.com/wp-json/wp/v2/posts/$id?_embed'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return {};
  }

  String? getFeaturedImage(Map post) {
    try {
      final embedded = post['_embedded'];
      final media = embedded['wp:featuredmedia'];
      if (media != null && media.length > 0) {
        return media[0]['source_url'];
      }
    } catch (e) {}
    return null;
  }

  void reset({int? categoryId}) {
    posts.clear();
    page = 1;
    hasMore = true;
    isSearching = false;
    this.categoryId = categoryId;
    notifyListeners();
  }
}
