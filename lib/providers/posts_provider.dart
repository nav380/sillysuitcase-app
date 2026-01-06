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

  // Fetch posts (normal or category)
  Future<void> fetchPosts({String? token, int? categoryId}) async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    this.categoryId = categoryId;

    final url = Uri.parse(
        'https://sillysuitcase.com/wp-json/wp/v2/posts?page=$page&per_page=5&_embed${categoryId != null ? "&categories=$categoryId" : ""}');

    try {
      debugPrint('📡 FETCH REQUEST: $url');
      
      final response = await http.get(
        url,
        headers: {
          // More realistic browser headers to bypass bot protection
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
          'Accept': 'application/json',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Referer': 'https://sillysuitcase.com/',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json')) {
          errorMessage = 'Server returned non-JSON response';
          hasMore = false;
          isLoading = false;
          notifyListeners();
          return;
        }

        final data = jsonDecode(response.body);
        
        // Check if it's an error message from bot protection
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
          debugPrint('❌ API Error: ${data['message']}');
          hasMore = false;
          isLoading = false;
          notifyListeners();
          return;
        }
        
        // Check if it's a valid posts array
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
      } else if (response.statusCode == 400) {
        debugPrint('⚠️ Bad request (400) - No more posts');
        hasMore = false;
      } else {
        debugPrint('❌ HTTP Error ${response.statusCode}');
        errorMessage = 'Server error: ${response.statusCode}';
        hasMore = false;
      }
    } on FormatException catch (e) {
      debugPrint('❌ FORMAT EXCEPTION: $e');
      errorMessage = 'Invalid response format';
      hasMore = false;
    } catch (e) {
      debugPrint('❌ GENERAL ERROR: $e');
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // Search posts
  Future<void> searchPosts({required String query}) async {
    isSearching = true;
    searchQuery = query;
    page = 1;
    posts.clear();
    hasMore = true;
    errorMessage = null;
    notifyListeners();

    final url = Uri.parse(
        'https://sillysuitcase.com/wp-json/wp/v2/posts?search=$query&per_page=5&_embed${categoryId != null ? "&categories=$categoryId" : ""}');

    try {
      debugPrint('🔍 SEARCH REQUEST: $url');
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
          'Accept': 'application/json',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Referer': 'https://sillysuitcase.com/',
        },
      );

      debugPrint('📥 Search Response Status: ${response.statusCode}');
      debugPrint('📥 Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json')) {
          errorMessage = 'Server returned non-JSON response';
          hasMore = false;
          isLoading = false;
          notifyListeners();
          return;
        }

        final data = jsonDecode(response.body);
        
        // Check for bot protection error
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
          debugPrint('❌ Search API Error: ${data['message']}');
          hasMore = false;
          isLoading = false;
          notifyListeners();
          return;
        }

        // Validate it's an array
        if (data is! List) {
          errorMessage = 'Unexpected search response';
          debugPrint('❌ Expected List but got: ${data.runtimeType}');
          hasMore = false;
          isLoading = false;
          notifyListeners();
          return;
        }

        debugPrint('✅ Search decoded: ${data.length} results');
        
        posts.addAll(data);
        if (data.isEmpty) hasMore = false;
        page++;
      }
    } on FormatException catch (e) {
      debugPrint('❌ SEARCH FORMAT EXCEPTION: $e');
      errorMessage = 'Invalid search response';
      hasMore = false;
    } catch (e) {
      debugPrint('❌ SEARCH ERROR: $e');
      errorMessage = e.toString();
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
    try {
      debugPrint('📄 Fetching single post: $id');
      
      final response = await http.get(
        Uri.parse('https://sillysuitcase.com/wp-json/wp/v2/posts/$id?_embed'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
          'Accept': 'application/json',
          'Accept-Language': 'en-US,en;q=0.9',
          'Referer': 'https://sillysuitcase.com/',
        },
      );

      debugPrint('📥 Single Post Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('application/json')) {
          final data = jsonDecode(response.body);
          
          // Check for error message
          if (data is Map && data.containsKey('message') && !data.containsKey('id')) {
            debugPrint('❌ Single post error: ${data['message']}');
            return {};
          }
          
          return data;
        } else {
          debugPrint('❌ Single post returned HTML');
        }
      }
    } on FormatException catch (e) {
      debugPrint('❌ Single post format error: $e');
    } catch (e) {
      debugPrint('❌ Single post error: $e');
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

  Future<void> reset({int? categoryId, String? token}) async {
    debugPrint('🔄 RESET called');
    posts.clear();
    page = 1;
    hasMore = true;
    isSearching = false;
    errorMessage = null;
    this.categoryId = categoryId;
    notifyListeners();
    
    // Fetch posts after reset
    await fetchPosts(token: token, categoryId: categoryId);
  }
}