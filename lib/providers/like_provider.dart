import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LikeProvider with ChangeNotifier {
  final String baseUrl = 'https://sillysuitcase.com/wp-json/custom/v1';

  final Map<int, int> _likeCounts = {};
  final Map<int, bool> _likedStatus = {};

  int getLikes(int postId) => _likeCounts[postId] ?? 0;
  bool isLiked(int postId) => _likedStatus[postId] ?? false;

  /// GET likes + status
  Future<void> fetchLikeStatus({
    required int postId,
    required String? token,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/post-like?post_id=$postId'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _likeCounts[postId] = data['likes'];
      _likedStatus[postId] = data['liked'];
      notifyListeners();
    }
  }

  /// POST like/unlike
  Future<void> toggleLike({
    required int postId,
    required String token,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/like-post'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'post_id': postId,
        'action': isLiked(postId) ? 'unlike' : 'like',
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _likeCounts[postId] = data['likes'];
      _likedStatus[postId] = data['liked'];
      notifyListeners();
    }
  }
}
