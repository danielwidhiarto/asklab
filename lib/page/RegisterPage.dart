import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true; // For password visibility toggle

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF009ADB), // Background color
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'AskLab', // Title of the app
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Email Field
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
                  prefixIcon: const Icon(Icons.email, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 16),
              // Password Field with Toggle Visibility
              TextField(
                style: const TextStyle(color: Colors.black),
                obscureText: _obscureText, // Toggle password visibility
                decoration: InputDecoration(
                  hintText: 'Password',
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
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Register Button with Hover Effect
              MouseRegion(
                onEnter: (_) {
                  // Optional: Change hover effect
                },
                onExit: (_) {
                  // Optional: Reset hover effect
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Handle registration action
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 16, color: Color(0xFF009ADB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Legal Text: Privacy Policy & Terms
              const Text(
                'By signing up, you agree to our ',
                style: TextStyle(color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to Privacy Policy
                    },
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Text(
                    ' and ',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Terms of Service
                    },
                    child: const Text(
                      'Terms of Service',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Divider
              const Divider(
                color: Colors.white,
                thickness: 0.5,
              ),
              const SizedBox(height: 20),
              // Sign Up Link - Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to login page
                    },
                    child: const Text(
                      'Login',
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
