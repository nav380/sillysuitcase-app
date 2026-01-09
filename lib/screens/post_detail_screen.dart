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
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Post Details',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                if (!snapshot.hasData)
                  return const Center(child: Text("Post not found"));

                final post = snapshot.data!;
                final imageUrl = postsProvider.getFeaturedImage(post);
                final htmlContent = post['content']?['rendered'] ?? '';

                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      Text(
                        post['title']?['rendered'] ?? '',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (post['date'] != null)
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a')
                              .format(DateTime.parse(post['date'])),
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),

                      const SizedBox(height: 20),

                      // ------------- HTML + CSS Classes Combined -------------
                      Html(
                        data: htmlContent,
                        style: {
                          // -------- Base Body --------
                          "body": Style(
                            fontFamily: "Inter",
                            color: const Color(0xFF222222),
                            fontSize: FontSize(16),
                            lineHeight: LineHeight.number(1.7),
                          ),

                          // -------- Headings --------
                          "h1": Style(
                              fontSize: FontSize(28),
                              fontWeight: FontWeight.bold),
                          "h2": Style(
                              fontSize: FontSize(24),
                              fontWeight: FontWeight.bold),
                          "h3": Style(
                              fontSize: FontSize(20),
                              fontWeight: FontWeight.w600),
                          "p": Style(margin: Margins.only(bottom: 12)),

                          // -------- Blockquote --------
                          "blockquote": Style(
                            backgroundColor: Colors.grey.shade200,
                            padding: HtmlPaddings.all(12),
                            border: Border(
                                left:
                                    BorderSide(color: Colors.indigo, width: 4)),
                            margin: Margins.symmetric(vertical: 14),
                          ),

                          // -------- Lists --------
                          "ul": Style(margin: Margins.only(left: 16)),
                          "ol": Style(margin: Margins.only(left: 16)),
                          "li": Style(margin: Margins.only(bottom: 6)),

                          // -------- Table --------
                          "table":
                              Style(border: Border.all(color: Colors.grey)),
                          "th": Style(
                            padding: HtmlPaddings.all(10),
                            backgroundColor: Colors.grey.shade300,
                            fontWeight: FontWeight.bold,
                          ),
                          "td": Style(padding: HtmlPaddings.all(10)),

                          // -------- Images --------
                          "img": Style(margin: Margins.symmetric(vertical: 16)),

                          // -------- CSS Classes from user --------

                          ".header-section h1": Style(
                            margin: Margins.only(bottom: 12),
                            fontSize: FontSize.xLarge,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111111),
                          ),

                          ".tag": Style(
                            backgroundColor:
                                const Color(0xFF8FC156).withOpacity(.22),
                            padding: HtmlPaddings.symmetric(
                                vertical: 6, horizontal: 14),
                            border: Border.all(color: Colors.transparent),
                            fontWeight: FontWeight.w600,
                            fontSize: FontSize(13),
                          ),

                          ".article-intro": Style(
                            backgroundColor: Colors.white,
                            padding: HtmlPaddings.all(20),
                          ),
                          ".attraction-detail": Style(
                            backgroundColor: Colors.white,
                            padding: HtmlPaddings.all(22),
                          ),
                          ".rating-item": Style(
                            backgroundColor: Colors.white.withOpacity(.65),
                            padding: HtmlPaddings.symmetric(
                                vertical: 10, horizontal: 14),
                          ),
                          ".review-card": Style(
                            padding: HtmlPaddings.all(12),
                            backgroundColor:
                                const Color(0xFFEFDDBA).withOpacity(.35),
                            border: Border(
                                left: BorderSide(
                                    color: Color(0xFFB76E79), width: 4)),
                          ),

                          ".reviewer-name": Style(fontWeight: FontWeight.bold),
                          ".info-box": Style(
                            padding: HtmlPaddings.all(18),
                            backgroundColor:
                                const Color(0xFFEFDDBA).withOpacity(.15),
                            border: Border.all(
                                color: const Color.fromARGB(40, 183, 110, 121)),
                          ),

                          ".legal-card": Style(
                            backgroundColor: const Color(0xFFFAFAF8),
                            padding: HtmlPaddings.all(15),
                            border: Border(
                                left: BorderSide(
                                    color: Color(0xFF8FC156), width: 3)),
                          ),
                        },

                        // -------- Link Handler --------
                        onLinkTap: (url, _, __) async {
                          if (url != null)
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                        },

                        // -------- iframe handler --------
                        extensions: [
                          TagExtension(
                            tagsToExtend: {"iframe"},
                            builder: (context) {
                              final src = context.attributes['src'];
                              if (src != null &&
                                  src.contains("google.com/maps")) {
                                final uri = Uri.parse(src);
                                final q = uri.queryParameters['q'];

                                if (q != null && q.contains(',')) {
                                  final parts = q.split(',');
                                  final lat = parts[0];
                                  final lng = parts[1];

                                  return ElevatedButton(
                                    onPressed: () {
                                      final geoUri = Uri.parse(
                                          "geo:$lat,$lng?q=$lat,$lng");
                                      debugPrint("geo:$lat,$lng?q=$lat,$lng");
                                      launchUrl(geoUri,
                                          mode: LaunchMode.externalApplication);
                                    },
                                    child: const Text("Open in Google Maps"),
                                  );
                                }
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
          const Footer(currentIndex: 4),
        ],
      ),
    );
  }
}
