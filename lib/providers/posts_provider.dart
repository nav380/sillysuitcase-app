import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostsProvider extends ChangeNotifier {
  List posts = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  // Fetch posts with optional token
  Future<void> fetchPosts({String? token}) async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('https://sillysuitcase.com/wp-json/wp/v2/posts?page=$page&per_page=5&_embed');

    try {
      final response = await http.get(
        url,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isEmpty || page > 5) hasMore = false;
        else {
          posts.addAll(data);
          page++;
        }
      }
    } catch (e) {
      print(e);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map> fetchSinglePost(int id) async {
    try {
      final response = await http.get(
        Uri.parse('https://sillysuitcase.com/wp-json/wp/v2/posts/$id?_embed'),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {}
    return {};
  }

  String? getFeaturedImage(Map post) {
    try {
      final embedded = post['_embedded'];
      final media = embedded['wp:featuredmedia'];
      if (media != null && media.length > 0) return media[0]['source_url'];
    } catch (e) {}
    return null;
  }

  // Post a comment using JWT
  Future<bool> postComment(int postId, String content, String token) async {
    final url = Uri.parse('https://sillysuitcase.com/wp-json/wp/v2/comments');
    try {
      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({
            'post': postId,
            'content': content,
          }));
      if (response.statusCode == 201) return true;
    } catch (e) {
      print(e);
    }
    return false;
  }
}
