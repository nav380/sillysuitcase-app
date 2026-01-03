import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_tile.dart';
import '../widgets/footer.dart';
import 'post_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  late ScrollController _scrollController;
  String query = '';

  @override
  void initState() {
    super.initState();
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          postsProvider.hasMore) {
        postsProvider.searchPosts(query: query);
      }
    });
  }

  void _startSearch(String q) {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    setState(() {
      query = q;
    });
    postsProvider.resetSearch();
    postsProvider.searchPosts(query: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search posts...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _startSearch(_searchController.text),
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => _startSearch(value),
        ),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PostsProvider>(
              builder: (context, provider, child) {
                if (provider.isSearching && provider.posts.isEmpty)
                  return Center(child: CircularProgressIndicator());

                if (!provider.isSearching && provider.posts.isEmpty)
                  return Center(child: Text('No posts found'));

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.posts.length) {
                      return Center(child: CircularProgressIndicator());
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
                            builder: (_) => PostDetailScreen(postId: post['id']),
                          ),
                        );
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
