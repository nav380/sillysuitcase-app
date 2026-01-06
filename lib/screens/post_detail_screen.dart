import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../providers/posts_provider.dart';
import '../widgets/footer.dart';

class PostDetailScreen extends StatelessWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Post Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map>(
              future: postsProvider.fetchSinglePost(postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("Post not found"));
                }

                final post = snapshot.data!;
                final imageUrl = postsProvider.getFeaturedImage(post);
                final htmlContent = post['content']?['rendered'] ?? '';

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FEATURED IMAGE
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 240,
                            fit: BoxFit.cover,
                          ),
                        ),

                      const SizedBox(height: 16),

                      // POST TITLE
                      Text(
                        post['title']?['rendered'] ?? '',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // POST DATE
                      if (post['date'] != null)
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a')
                              .format(DateTime.parse(post['date'])),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),

                      const SizedBox(height: 20),

                      // HTML CONTENT
                      Html(
                        data: htmlContent,
                        style: {
                          "body": Style(
                            fontSize: FontSize(16),
                            lineHeight: LineHeight(1.7),
                            color: Colors.black87,
                          ),
                          "h1": Style(
                            fontSize: FontSize(26),
                            fontWeight: FontWeight.bold,
                            margin: Margins.only(bottom: 16),
                          ),
                          "h2": Style(
                            fontSize: FontSize(22),
                            fontWeight: FontWeight.w600,
                            margin: Margins.only(top: 20, bottom: 12),
                          ),
                          "h3": Style(
                            fontSize: FontSize(18),
                            fontWeight: FontWeight.w600,
                            margin: Margins.only(bottom: 8),
                          ),
                          "p": Style(margin: Margins.only(bottom: 12)),
                          "li": Style(margin: Margins.only(bottom: 10)),
                          "strong": Style(fontWeight: FontWeight.bold),
                          "img": Style(
                            height: Height(300),
                            margin: Margins.symmetric(vertical: 16),
                          ),
                        },
                        onLinkTap: (url, _, __) async {
                          if (url == null) return;
                          await launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        },
                        extensions: [
                          TagExtension(
                            tagsToExtend: {"iframe"},
                            builder: (context) {
                              final src = context.attributes['src'];
                              if (src != null && src.contains("google.com/maps")) {
                                return Container(
                                  height: 220,
                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.map),
                                    label: const Text("Open Map"),
                                    onPressed: () async {
                                      await launchUrl(
                                        Uri.parse(src),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // FOOTER
          const Footer(currentIndex: 4),
        ],
      ),
    );
  }
}
