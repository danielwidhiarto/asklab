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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String _domain = 'binus.edu';

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleDomain() {
    setState(() {
      _domain = _domain == 'binus.edu' ? 'binus.ac.id' : 'binus.edu';
    });
  }

  Future<void> _registerUser() async {
    try {
      String email = _emailController.text.trim() + '@$_domain';
      String username = _usernameController.text.trim();

      if (username.isEmpty || email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username and email cannot be empty')),
        );
        return;
      }

      var checkUser = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1).get();

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      if (checkUser.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username already exists')),
        );
        return;
      }

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'username': username,
        'fullName': null,
        'profilePicture': null,
        'bio': null,
        'followersCount': 0,
        'followingCount': 0,
        'postCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection("users").doc(userCredential.user?.uid).
      collection("followers_following").doc(userCredential.user?.uid).set({
        'followers': [],
        'following': []
      });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
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
              Container(
                width: double.infinity,
                child: TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Username',
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
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
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
                      onTap: _toggleDomain,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '@$_domain',
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
              Container(
                width: double.infinity,
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
              MouseRegion(
                onEnter: (_) {},
                onExit: (_) {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
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
              const Divider(
                color: Colors.white,
                thickness: 0.5,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
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
