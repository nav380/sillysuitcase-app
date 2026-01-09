import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/profile_screen.dart';
import '../providers/posts_provider.dart';

class Footer extends StatelessWidget {
  final int currentIndex;

  const Footer({
    super.key,
    required this.currentIndex,
  });

  static const Color activeColor = Color(0xff0D47A1); // Premium Blue
  static const Color inactiveColor = Color(0xffA0A0A0); // Grey

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(
            context,
            icon: Icons.home,
            index: 0,
            screen: const HomeScreen(),
            resetPosts: true, // 👈 Reset posts on Home click
          ),
          _navItem(
            context,
            icon: Icons.search,
            index: 1,
            screen: const SearchScreen(),
          ),
          _navItem(
            context,
            icon: Icons.person,
            index: 2,
            screen: const ProfileScreen(),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required int index,
    required Widget screen,
    bool resetPosts = false, // optional
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          // 🔹 Reset Home posts if needed
          if (resetPosts) {
            final provider = context.read<PostsProvider>();
            provider.reset(); // Clears posts, resets hasMore & page, fetches first page
          }

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => screen,
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: isActive ? 32 : 28,
          color: isActive ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}
