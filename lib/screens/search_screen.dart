import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_tile.dart';
import 'post_detail_screen.dart';
import '../widgets/footer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? _selectedCategory;

  @override
  bool get wantKeepAlive => true; // ✅ Preserve scroll

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollListener);

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PostsProvider>(context, listen: false);
      if (provider.posts.isEmpty) provider.fetchPosts(categoryId: _selectedCategory);
    });
  }

  void _scrollListener() {
    final provider = Provider.of<PostsProvider>(context, listen: false);

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (provider.isLoading || !provider.hasMore) return;

      if (provider.isSearching) {
        provider.searchPosts(query: _searchController.text, loadMore: true);
      } else {
        provider.fetchPosts(categoryId: _selectedCategory);
      }
    }
  }

  Future<void> _onSearch() async {
    final provider = Provider.of<PostsProvider>(context, listen: false);
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      provider.reset();
      provider.fetchPosts(categoryId: _selectedCategory);
    } else {
      await provider.searchPosts(query: query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final provider = Provider.of<PostsProvider>(context, listen: false);
    provider.reset();
    provider.fetchPosts(categoryId: _selectedCategory);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // For AutomaticKeepAliveClientMixin
    final provider = Provider.of<PostsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF6F7F9),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _onSearch(),
                decoration: InputDecoration(
                  hintText: 'Search country...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),

          // 🔎 SEARCH INFO
          if (provider.isSearching)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Results for "${provider.searchQuery}"',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _clearSearch,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // 📄 POSTS LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.posts.length) {
                  // 🔄 Show loader only at bottom
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final post = provider.posts[index];
                return PostTile(
                  title: post['title']['rendered'],
                  excerpt: post['excerpt']['rendered'],
                  imageUrl: provider.getFeaturedImage(post),
                  postId: post['id'],
                  postLink: post['link'],
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
            ),
          ),

          const Footer(currentIndex: 1),
        ],
      ),
    );
  }
}
