import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_tile.dart';
import 'post_detail_screen.dart';
import '../widgets/footer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int? _selectedCategory;
  final _searchController = TextEditingController();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostsProvider>(context, listen: false).fetchPosts();
    });
  }

  void _scrollListener() {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !postsProvider.isLoading &&
        postsProvider.hasMore) {
      
      if (postsProvider.isSearching) {
        postsProvider.searchPosts(query: _searchController.text);
      } else {
        postsProvider.fetchPosts(categoryId: _selectedCategory);
      }
    }
  }

  void _onSearch() async {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);

    if (_searchController.text.isNotEmpty) {
      await postsProvider.searchPosts(query: _searchController.text);
    } else {
      postsProvider.reset(categoryId: _selectedCategory);
      await postsProvider.fetchPosts(categoryId: _selectedCategory);
    }
  }

  void _onCategoryChanged(int? categoryId) {
    setState(() => _selectedCategory = categoryId);
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    
    if (_searchController.text.isNotEmpty) {
      postsProvider.searchPosts(query: _searchController.text);
    } else {
      postsProvider.reset(categoryId: categoryId);
      postsProvider.fetchPosts(categoryId: categoryId);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    postsProvider.resetSearch();
    postsProvider.fetchPosts(categoryId: _selectedCategory);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsProvider = Provider.of<PostsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF6F7F9),
      body: Column(
        children: [
          // 🔹 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search posts...',
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
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 0, horizontal: 16),
                ),
                onSubmitted: (_) => _onSearch(),
              ),
            ),
          ),

          // 🔹 CATEGORY DROPDOWN (Optional)
          /*
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<int>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                // Add your categories here
              ],
              onChanged: _onCategoryChanged,
            ),
          ),
          */

          // 🔹 SEARCHING INDICATOR
          if (postsProvider.isSearching)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      'Searching for: "${postsProvider.searchQuery}"',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _clearSearch,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // 🔹 POSTS LIST
          Expanded(
            child: postsProvider.isLoading && postsProvider.posts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : postsProvider.posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              postsProvider.isSearching
                                  ? 'No results found'
                                  : 'No posts found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        itemCount: postsProvider.posts.length +
                            (postsProvider.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == postsProvider.posts.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final post = postsProvider.posts[index];
                          return PostTile(
                            title: post['title']['rendered'],
                            excerpt: post['excerpt']['rendered'],
                            imageUrl: postsProvider.getFeaturedImage(post),
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
