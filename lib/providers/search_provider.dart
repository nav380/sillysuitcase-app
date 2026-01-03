import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostsProvider extends ChangeNotifier {
  List posts = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  bool isSearching = false;
  String currentQuery = '';

  /// Fetch regular posts
  Future<void> fetchPosts({String? token}) async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'https://sillysuitcase.com/wp-json/wp/v2/posts?page=$page&per_page=5&_embed');

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

  /// Fetch single post by ID
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

  /// Get featured image from post
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

  /// Reset search state
  void resetSearch() {
    posts = [];
    page = 1;
    hasMore = true;
    isSearching = true;
    currentQuery = '';
    notifyListeners();
  }

  /// Search posts by query
  Future<void> searchPosts({required String query}) async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();

    currentQuery = query;

    final url = Uri.parse(
        'https://sillysuitcase.com/wp-json/wp/v2/posts?search=$query&page=$page&per_page=5&_embed');

    try {
      final response = await http.get(url);

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
}
