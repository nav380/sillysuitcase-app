import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/posts_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/like_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  
  // Auth Provider
  final authProvider = AuthProvider();
  await authProvider.loadToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SillySuitcase',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return authProvider.token != null
              ? const HomeScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}
