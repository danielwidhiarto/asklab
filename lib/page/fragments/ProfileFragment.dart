import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../EditProfilePage.dart'; // Import Edit Profile Page

class ProfileFragment extends StatefulWidget {
  const ProfileFragment({Key? key}) : super(key: key);

  @override
  _ProfileFragmentState createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? fullName;
  String? username;
  String? bio;
  String? profilePicture;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          fullName = userDoc['fullName'];
          username = userDoc['username'];
          bio = userDoc['bio'];
          profilePicture = userDoc['profilePicture'];
          postCount = userDoc['postCount'];
          followersCount = userDoc['followersCount'];
          followingCount = userDoc['followingCount'];
        });
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(
        context, '/'); // Navigate to login page after logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF009ADB),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Foto Profil
            CircleAvatar(
              radius: 50,
              backgroundImage: profilePicture != null
                  ? NetworkImage(profilePicture!) as ImageProvider
                  : const AssetImage('assets/profile_picture.png'),
            ),

            const SizedBox(height: 10),

            // Full Name
            if (fullName != null)
              Text(
                fullName!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 5),

            // Username dan Info Posts, Followers, Following
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username
                  Text(
                    '@${username ?? "username"}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  // Info Followers, Following, Posts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      profileInfo("Posts", "$postCount"),
                      profileInfo("Followers", "$followersCount"),
                      profileInfo("Following", "$followingCount"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bio (jika ada)
            if (bio != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  bio!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),

            const SizedBox(height: 20),

            // Tombol Edit Profile & Logout (Modern Style)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Aksi Edit Profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Edit Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009ADB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout,
                      size: 18, color: Color(0xFF009ADB)),
                  label: const Text("Logout",
                      style: TextStyle(color: Color(0xFF009ADB))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF009ADB)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 30),

            // Grid List Postingan
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 10, // Jumlah post yang tersedia
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 kolom seperti Instagram
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(child: Text("Post ${index + 1}")),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileInfo(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
