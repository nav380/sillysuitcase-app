import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../providers/categories_provider.dart';
import '../widgets/post_tile.dart';
import 'post_detail_screen.dart';
import '../widgets/footer.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int? _selectedCategory;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final categoriesProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
    categoriesProvider.fetchCategories();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final postsProvider = Provider.of<PostsProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        postsProvider.fetchPosts(categoryId: _selectedCategory);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoriesProvider>(context);
    final postsProvider = Provider.of<PostsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search by Category'),
      ),
      body: Column(
        children: [
          // Dropdown for categories
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: categoriesProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    value: _selectedCategory,
                    items: categoriesProvider.categories
                        .map<DropdownMenuItem<int>>((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        postsProvider.reset(categoryId: value);
                        postsProvider.fetchPosts(categoryId: value);
                      });
                    },
                  ),
          ),

          Expanded(
            child: postsProvider.posts.isEmpty
                ? Center(child: Text('No posts found'))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        postsProvider.posts.length + (postsProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == postsProvider.posts.length)
                        return Center(child: CircularProgressIndicator());

                      final post = postsProvider.posts[index];
                      return PostTile(
                        title: post['title']['rendered'],
                        excerpt: post['excerpt']['rendered'],
                        imageUrl: postsProvider.getFeaturedImage(post),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PostDetailScreen(postId: post['id'])),
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
