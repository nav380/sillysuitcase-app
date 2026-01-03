import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SillySuitcase',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: authProvider.token == null ? LoginScreen() : HomeScreen(),
    );
  }
}
