import 'package:asklab/page/DetailPost.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '';
import '../EditProfilePage.dart';

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
    _fetchPostCount();
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
          followersCount = userDoc['followersCount'] ?? 0;
          followingCount = userDoc['followingCount'] ?? 0;
        });
      }
    }
  }

  Future<void> _fetchPostCount() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    QuerySnapshot postSnapshot = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: user.uid)
        .get();

    setState(() {
      postCount = postSnapshot.size;
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
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

            // Avatar Profile dari Cloudinary
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueAccent,
              backgroundImage:
                  profilePicture != null ? NetworkImage(profilePicture!) : null,
              child: profilePicture == null
                  ? const Icon(Icons.account_circle,
                      size: 80, color: Colors.white)
                  : null,
            ),

            const SizedBox(height: 10),

            // Nama & Username
            if (fullName != null)
              Text(fullName!,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            Text('@${username ?? "username"}',
                style: const TextStyle(fontSize: 16, color: Colors.grey)),

            const SizedBox(height: 15),

            // Statistik User (Real-time update dengan StreamBuilder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('posts')
                        .where('userId', isEqualTo: _auth.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      int postCount =
                          snapshot.hasData ? snapshot.data!.size : 0;
                      return profileInfo("Posts", "$postCount");
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(_auth.currentUser?.uid)
                        .collection('followers')
                        .snapshots(),
                    builder: (context, snapshot) {
                      int followersCount =
                          snapshot.hasData ? snapshot.data!.size : 0;
                      return profileInfo("Followers", "$followersCount");
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(_auth.currentUser?.uid)
                        .collection('following')
                        .snapshots(),
                    builder: (context, snapshot) {
                      int followingCount =
                          snapshot.hasData ? snapshot.data!.size : 0;
                      return profileInfo("Following", "$followingCount");
                    },
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),

            const SizedBox(height: 20),

            // Tombol Edit Profile & Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 20),
                      label: const Text("Edit Profile",
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout,
                          size: 20, color: Colors.blueAccent),
                      label: const Text("Logout",
                          style: TextStyle(
                              fontSize: 16, color: Colors.blueAccent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueAccent),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 30),

            // Grid Postingan
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
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      var post = posts[index];
                      String? imageUrl =
                          post['images'].isNotEmpty ? post['images'][0] : null;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPost(
                                postId: post.id,
                                title: post['title'],
                                images: List<String>.from(post['images']),
                                description: post['description'],
                                timestamp: post['timestamp'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
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
                        ),
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
        Text(count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
