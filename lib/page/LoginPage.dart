import 'package:asklab/page/RegisterPage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true; // For password visibility toggle
  bool _isButtonHovered = false; // For button hover animation

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Handle button hover animation
  void _onButtonHover(bool isHovered) {
    setState(() {
      _isButtonHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF009ADB), // Updated background color
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Name or Logo
              const Text(
                'AskLab',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Username Field
              TextField(
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 16),
              // Password Field
              TextField(
                style: const TextStyle(color: Colors.black),
                obscureText: _obscureText, // Toggle password visibility
                decoration: InputDecoration(
                  hintText: 'Password', // Disappears when typing
                  hintStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black54,
                    ),
                    onPressed: _togglePasswordVisibility, // Toggle visibility
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Handle forgotten password
                  },
                  child: const Text(
                    'Forgotten password?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Login Button with hover animation
              MouseRegion(
                onEnter: (_) => _onButtonHover(true),
                onExit: (_) => _onButtonHover(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isButtonHovered
                        ? const Color(0xFF007BB6) // Darker blue on hover
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Handle login action
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(fontSize: 16, color: Color(0xFF009ADB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                    child: Divider(
                      color: Colors.white,
                      thickness: 0.5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white,
                      thickness: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Log in with Microsoft
              TextButton.icon(
                onPressed: () {
                  // Handle login with Microsoft
                },
                icon: const Icon(Icons.email, color: Colors.white),
                label: const Text(
                  'Log in with Microsoft',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
