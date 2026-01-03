import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class PostTile extends StatelessWidget {
  final String title;
  final String excerpt;
  final String? imageUrl;
  final VoidCallback onTap;

  PostTile({
    required this.title,
    required this.excerpt,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Stack(
                children: [
                  Image.network(
                    imageUrl!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Html(data: excerpt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
