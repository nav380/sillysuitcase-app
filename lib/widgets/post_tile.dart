import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/auth_provider.dart';
import '../providers/like_provider.dart';
import '../screens/comment_screen.dart';

class PostTile extends StatelessWidget {
  final int postId;
  final String title;
  final String excerpt;
  final String postLink;
  final String? imageUrl;
  final VoidCallback onTap;

  const PostTile({
    super.key,
    required this.postId,
    required this.title,
    required this.excerpt,
    required this.postLink,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final jwtToken = auth.token;

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 FEATURED IMAGE
            if (imageUrl != null)
              Stack(
                children: [
                  Image.network(
                    imageUrl!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔹 TITLE
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E293B),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 🔹 EXCERPT
                  Html(
                    data: excerpt,
                    style: {
                      "*": Style(
                        color: const Color(0xff4B5563),
                        fontSize: FontSize(14),
                      ),
                    },
                  ),

                  const SizedBox(height: 14),

                  // 🔹 ACTION ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // ❤️ LIKE BUTTON + COUNT
                      Consumer<LikeProvider>(
                        builder: (context, likeProvider, _) {
                          final isLiked = likeProvider.isLiked(postId);
                          final likes = likeProvider.getLikes(postId);

                          return Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  if (jwtToken == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Login to like this post'),
                                      ),
                                    );
                                    return;
                                  }

                                  likeProvider.toggleLike(
                                    postId: postId,
                                    token: jwtToken,
                                  );
                                },
                              ),
                              Text(
                                likes.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff374151),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // 💬 COMMENT + 🔗 SHARE
                      Row(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.comment, size: 20),
                            label: const Text('Comment'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xff0D47A1),
                              side: const BorderSide(
                                  color: Color(0xff0D47A1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: jwtToken == null
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CommentScreen(
                                          postId: postId,
                                          jwtToken: jwtToken,
                                        ),
                                      ),
                                    );
                                  },
                          ),

                          const SizedBox(width: 10),

                          OutlinedButton.icon(
                            icon: const Icon(Icons.share, size: 20),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xff0D47A1),
                              side: const BorderSide(
                                  color: Color(0xff0D47A1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Share.share(
                                '$title\n\nRead more 👉 $postLink',
                                subject: title,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
