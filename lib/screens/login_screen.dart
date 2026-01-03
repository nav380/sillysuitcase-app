import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import '../widgets/footer.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  void _launchWebsite() async {
    final url = Uri.parse('https://sillysuitcase.com/wp-login.php?action=register');
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cannot open website')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/icon/sillysuitcase.png',
                          width: 100,
                          height: 100,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Login to SillySuitcase',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),

                        // Error message box
                        if (_errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Username & Password
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20),

                        // Login button
                        _loading
                            ? CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      _loading = true;
                                      _errorMessage = null;
                                    });
                                    bool success = await authProvider.login(
                                        _usernameController.text,
                                        _passwordController.text);
                                    setState(() => _loading = false);

                                    if (success) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => HomeScreen()),
                                      );
                                    } else {
                                      setState(() {
                                        _errorMessage =
                                            'Username or password is wrong';
                                      });
                                    }
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),

                        SizedBox(height: 16),

                        // Register link
                        GestureDetector(
                          onTap: _launchWebsite,
                          child: Text(
                            'Don’t have an account? Register on our website',
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Footer(), // Footer with Home/Login buttons
        ],
      ),
    );
  }
}
