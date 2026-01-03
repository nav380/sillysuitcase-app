import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_tile.dart';
import '../widgets/footer.dart';
import 'post_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);

    // Load initial posts
    postsProvider.fetchPosts(token: authProvider.token);

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        postsProvider.fetchPosts(token: authProvider.token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postsProvider = Provider.of<PostsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('SillySuitcase Posts'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SearchScreen()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PostsProvider>(
              builder: (context, provider, child) {
                if (provider.posts.isEmpty && provider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.posts.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final post = provider.posts[index];
                    return PostTile(
                      title: post['title']['rendered'],
                      excerpt: post['excerpt']['rendered'],
                      imageUrl: provider.getFeaturedImage(post),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PostDetailScreen(postId: post['id']),
                          ),
                        );
                      },
                      onCommentTap: () async {
                        final success = await provider.postComment(
                            post['id'], "This is a test comment", authProvider.token!);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success ? 'Comment posted!' : 'Failed to post comment'),
                        ));
                      },
                      onSaveTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Saved post!'),
                        ));
                      },
                    );
                  },
                );
              },
            ),
          ),
          Footer(),
        ],
      ),
    );
  }
}
