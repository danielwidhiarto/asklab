import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String _domain = 'binus.edu'; // Default domain

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Toggle email domain between @binus.edu and @binus.ac.id
  void _toggleDomain() {
    setState(() {
      _domain = _domain == 'binus.edu' ? 'binus.ac.id' : 'binus.edu';
    });
  }

  // Register User
  Future<void> _registerUser() async {
    try {
      // Get the email input from the user (without domain)
      String email = _emailController.text.trim() + '@$_domain';

      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email, // Use the modified email with domain
        password: _passwordController.text,
      );

      // Add user to Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email, // Store the email with the selected domain in Firestore
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate to login page or home page
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF009ADB),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'AskLab',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 40),
              // Email Field (user only inputs the part before @)
              Container(
                width: double.infinity, // Ensure it takes full width
                child: TextField(
                  controller: _emailController,
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
                    suffixIcon: GestureDetector(
                      onTap: _toggleDomain, // Toggle domain on tap
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '@$_domain', // Show dynamic domain
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Password Field with Toggle Visibility
              Container(
                width: double.infinity, // Ensure it takes full width
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  style: const TextStyle(color: Colors.black),
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
              ),
              const SizedBox(height: 20),
              // Register Button
              MouseRegion(
                onEnter: (_) {},
                onExit: (_) {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity, // Ensure it takes full width
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextButton(
                    onPressed: _registerUser,
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
