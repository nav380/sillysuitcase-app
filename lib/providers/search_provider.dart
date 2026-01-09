import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostsProvider extends ChangeNotifier {
  List posts = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  String? errorMessage;

  // For search
  bool isSearching = false;
  String? searchQuery;
  int? categoryId;
  final String proxyBase = 'http://localhost:8000/fetch'; // <-- Replace with your Python server

  // Helper: build proxy URL
  Uri buildProxyUri({String? wpUrl}) {
    return Uri.parse('$proxyBase?url=${Uri.encodeComponent(wpUrl!)}');
  }

  // Fetch posts (normal or category)
  Future<void> fetchPosts({String? token, int? categoryId}) async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    this.categoryId = categoryId;

    // Build WordPress API URL
    final wpUrl =
        'https://sillysuitcase.com/wp-json/wp/v2/posts?page=$page&per_page=5&_embed';

    final url = buildProxyUri(wpUrl: wpUrl);

    try {
      debugPrint('📡 FETCH REQUEST (via proxy): $url');
      final response = await http.get(url);

      debugPrint('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data.containsKey('error')) {
          errorMessage = data['error'];
          debugPrint('❌ Proxy Error: $errorMessage');
          hasMore = false;
          isLoading = false;
          notifyListeners();
          return;
        }

        if (data is! List) {
          errorMessage = 'Unexpected response format';
          debugPrint('❌ Expected List but got: ${data.runtimeType}');
          hasMore = false;
          isLoading = false;
          notifyListeners();
          return;
        }

        debugPrint('✅ Decoded successfully: ${data.length} posts');

        if (data.isEmpty || page > 5) {
          hasMore = false;
        } else {
          posts.addAll(data);
          page++;
        }
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
        hasMore = false;
      }
    } catch (e) {
      debugPrint('❌ FETCH ERROR: $e');
      errorMessage = e.toString();
      hasMore = false;
    }

    isLoading = false;
    notifyListeners();
  }

  // Search posts via proxy
 Future<void> searchPosts({required String query}) async {
  isSearching = true;
  searchQuery = query;
  page = 1;
  posts.clear();
  hasMore = true;
  errorMessage = null;
  notifyListeners();

  final q = query.toLowerCase().trim();

  try {
    /// -----------------------------
    /// 1️⃣ Fetch ALL categories
    /// -----------------------------
    final catUrl = buildProxyUri(
      wpUrl:
          'https://sillysuitcase.com/wp-json/wp/v2/categories?per_page=100',
    );

    final catResponse = await http.get(catUrl);

    int? matchedCategoryId;

    if (catResponse.statusCode == 200) {
      final List categories = jsonDecode(catResponse.body);

      Map<String, dynamic>? exactMatch;
      Map<String, dynamic>? partialMatch;

      for (final cat in categories) {
        final name = cat['name']?.toString().toLowerCase() ?? '';
        final slug = cat['slug']?.toString().toLowerCase() ?? '';

        // 1️⃣ Exact match (highest priority)
        if (name == q || slug == q) {
          exactMatch = cat;
          break;
        }

        // 2️⃣ Partial match
        if (name.contains(q) || slug.contains(q)) {
          // Prefer child categories over parent
          if (partialMatch == null ||
              (cat['parent'] != 0 &&
                  partialMatch!['parent'] == 0)) {
            partialMatch = cat;
          }
        }
      }

      final matchedCat = exactMatch ?? partialMatch;
      matchedCategoryId = matchedCat?['id'];
    }

    /// -----------------------------
    /// 2️⃣ Build POSTS URL
    /// -----------------------------
    String wpUrl;

    if (matchedCategoryId != null) {
      wpUrl =
          'https://sillysuitcase.com/wp-json/wp/v2/posts'
          '?categories=$matchedCategoryId'
          '&per_page=10'
          '&page=$page'
          '&_embed';
      debugPrint('✅ Category match ID: $matchedCategoryId');
    } else {
      wpUrl =
          'https://sillysuitcase.com/wp-json/wp/v2/posts'
          '?search=$query'
          '&per_page=5'
          '&page=$page'
          '&_embed';
      debugPrint('🔍 Keyword search');
    }

    final postUrl = buildProxyUri(wpUrl: wpUrl);
    debugPrint('🔗 POSTS REQUEST: $postUrl');

    /// -----------------------------
    /// 3️⃣ Fetch POSTS
    /// -----------------------------
    final response = await http.get(postUrl);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        posts.addAll(data);
        if (data.length <= 4) hasMore = false;
        page++;
      } else {
        errorMessage = 'Unexpected response';
        hasMore = false;
      }
    } else {
      errorMessage = 'Failed to load posts';
      hasMore = false;
    }
  } catch (e) {
    debugPrint('❌ SEARCH ERROR: $e');
    errorMessage = e.toString();
    hasMore = false;
  }

  isLoading = false;
  notifyListeners();
}

  void resetSearch() {
    isSearching = false;
    searchQuery = null;
    page = 1;
    posts.clear();
    hasMore = true;
    errorMessage = null;
    notifyListeners();
  }

  Future<Map> fetchSinglePost(int id) async {
    final wpUrl = 'https://sillysuitcase.com/wp-json/wp/v2/posts/$id?_embed';
    final url = buildProxyUri(wpUrl: wpUrl);

    try {
      debugPrint('📄 Fetching single post (via proxy): $id');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data.containsKey('error')) {
          debugPrint('❌ Proxy Single Post Error: ${data['error']}');
          return {};
        }

        return data;
      }
    } catch (e) {
      debugPrint('❌ Single post fetch error: $e');
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

  Future<void> reset({int? categoryId}) async {
    posts.clear();
    page = 1;
    hasMore = true;
    isSearching = false;
    errorMessage = null;
    this.categoryId = categoryId;
    notifyListeners();

    await fetchPosts(categoryId: categoryId);
  }
}
