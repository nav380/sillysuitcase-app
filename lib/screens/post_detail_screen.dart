import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import 'package:flutter_html/flutter_html.dart';
import '../widgets/footer.dart';

class PostDetailScreen extends StatelessWidget {
  final int postId;

  PostDetailScreen({required this.postId});

  @override
  Widget build(BuildContext context) {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
        backgroundColor: const Color.fromARGB(255, 249, 249, 249),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map>(
              future: postsProvider.fetchSinglePost(postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                final post = snapshot.data ?? {};
                final imageUrl = postsProvider.getFeaturedImage(post);

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        Center(
                          child: Image.network(
                            imageUrl,
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 16),
                      Text(
                        post['title']?['rendered'] ?? '',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      Html(data: post['content']?['rendered'] ?? ''),
                    ],
                  ),
                );
              },
            ),
          ),
          Footer(), // Footer added here
        ],
      ),
    );
  }
}
