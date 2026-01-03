import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/search_screen.dart'; // You need to create this screen

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 248, 248, 248),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Home button
              IconButton(
                icon: Icon(Icons.home, size: 30, color: const Color.fromARGB(255, 98, 95, 95)),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
              ),

              SizedBox(width: 30),

              // Search button
              IconButton(
                icon: Icon(Icons.search, size: 30, color: const Color.fromARGB(255, 98, 95, 95)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchScreen()),
                  );
                },
              ),

              SizedBox(width: 30),

              // Login button
              IconButton(
                icon: Icon(Icons.login, size: 30, color: const Color.fromARGB(255, 88, 83, 83)),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
