// lib/models/wordpress_post.dart

class WordPressPost {
  final int id;
  final String title;
  final String imageUrl;

  WordPressPost({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory WordPressPost.fromJson(Map<String, dynamic> json) {
    return WordPressPost(
      id: json['id'],
      title: json['title']['rendered'],
      imageUrl: json['_embedded']?['wp:featuredmedia']?[0]?['source_url'] ??
          '',
    );
  }
}
