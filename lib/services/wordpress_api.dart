import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/wordpress_post.dart';

class WordPressApi {
  static const String baseUrl =
      "https://sillysuitcase.com/wp-json/wp/v2/posts";

  static Future<List<WordPressPost>> fetchLatestPosts() async {
    final url = Uri.parse("$baseUrl?per_page=10&_embed");

    try {
      debugPrint("📡 API CALL STARTED: $url");

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "User-Agent": "FlutterApp", // Helps avoid blocks on some servers
        },
      );

      
      debugPrint("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        debugPrint("POST COUNT: ${data.length}");
        return data.map((e) => WordPressPost.fromJson(e)).toList();
      } else {
        throw Exception(
          "HTTP ${response.statusCode}: ${response.body}",
        );
      }
    } catch (e) {
      debugPrint("🔥 API ERROR: $e");
      rethrow;
    }
  }
}
