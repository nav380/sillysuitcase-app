import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/posts_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/post_tile.dart';
import '../widgets/footer.dart';
import 'post_detail_screen.dart';
import '../screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    // Fetch posts after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<PostsProvider>().fetchPosts(token: auth.token);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      final auth = context.read<AuthProvider>();
      context.read<PostsProvider>().fetchPosts(token: auth.token);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7F9),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Animated Header
            const AnimatedAppHeader(),
            // 🔹 Hero Section
            _buildHeroSection(),
            // 🔹 Section Title
            _buildSectionTitle(),
            // 🔹 Posts List
            Expanded(child: _buildPosts()),
            // 🔹 Footer
            const Footer(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  // 🔹 HERO SECTION
  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "SillySuitcase ✈️",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0D47A1),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Travel guides, hidden gems & stories curated for curious explorers.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffE3F2FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(
                'assets/icon/sillysuitcase.png',
                height: 36,
                width: 36,
                fit: BoxFit.contain,
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🔹 SECTION TITLE
  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Latest Stories",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xff1E293B),
          ),
        ),
      ),
    );
  }

  // 🔹 POSTS LIST
  Widget _buildPosts() {
    return Consumer<PostsProvider>(
      builder: (context, provider, _) {
        if (provider.posts.isEmpty && provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
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
        );
      },
    );
  }
}

// 🔹 ANIMATED HEADER
class AnimatedAppHeader extends StatefulWidget {
  const AnimatedAppHeader({super.key});

  @override
  State<AnimatedAppHeader> createState() => _AnimatedAppHeaderState();
}

class _AnimatedAppHeaderState extends State<AnimatedAppHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final name = auth.userName ?? 'Traveler';

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0D47A1), Color(0xff1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, $name 👋",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Discover stories worth traveling for",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Color(0xff0D47A1),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
