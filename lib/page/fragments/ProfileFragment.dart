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
  int followersCount = 0;
  int followingCount = 0;
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchPostCount(); // Ambil jumlah post dari Firestore
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
          followersCount = userDoc['followersCount'];
          followingCount = userDoc['followingCount'];
        });
      }
    }
  }

  Future<void> _fetchPostCount() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    QuerySnapshot postSnapshot = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: user.uid) // Ambil hanya post milik user
        .get();

    setState(() {
      postCount =
          postSnapshot.size; // Ambil jumlah dokumen (post) yang dimiliki user
    });
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
              backgroundImage:
                  profilePicture != null && profilePicture!.isNotEmpty
                      ? NetworkImage(profilePicture!) as ImageProvider
                      : null,
              child: profilePicture == null || profilePicture!.isEmpty
                  ? const Icon(Icons.account_circle,
                      size: 50, color: Colors.grey)
                  : null,
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
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .where('userId', isEqualTo: _auth.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No posts yet"),
                    ),
                  );
                }

                var posts = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 kolom seperti Instagram
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      var post = posts[index];
                      String? imageUrl =
                          post['images'].isNotEmpty ? post['images'][0] : null;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          image: imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageUrl == null
                            ? const Center(child: Text("No Image"))
                            : null,
                      );
                    },
                  ),
                );
              },
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
