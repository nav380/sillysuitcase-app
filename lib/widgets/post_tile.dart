import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class PostTile extends StatelessWidget {
  final String title;
  final String excerpt;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onCommentTap;
  final VoidCallback onSaveTap;

  PostTile({
    required this.title,
    required this.excerpt,
    this.imageUrl,
    required this.onTap,
    required this.onCommentTap,
    required this.onSaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Html(data: excerpt),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onCommentTap,
                      icon: Icon(Icons.comment),
                      label: Text('Comment'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: onSaveTap,
                      icon: Icon(Icons.bookmark),
                      label: Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
