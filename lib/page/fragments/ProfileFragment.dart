import 'package:asklab/page/DetailPost.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        });
      }
    }
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
            const SizedBox(height: 10),

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
              Text(
                fullName!,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            Text(
              '@${username ?? "username"}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 10),

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

            const SizedBox(height: 15),

            // Statistik User (Real-time update dengan StreamBuilder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Posts
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
                  // Followers
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
                  // Following
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

            const SizedBox(height: 15),

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
                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(fontSize: 16),
                      ),
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
                      icon: const Icon(
                        Icons.logout,
                        size: 20,
                        color: Colors.blueAccent,
                      ),
                      label: const Text(
                        "Logout",
                        style:
                            TextStyle(fontSize: 16, color: Colors.blueAccent),
                      ),
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

            // ListView menampilkan Post (thumbnail + judul + deskripsi + timestamp)
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
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    List<String> images = List<String>.from(post['images']);
                    String? imageUrl = images.isNotEmpty ? images[0] : null;
                    String title = post['title'];
                    String description = post['description'];
                    Timestamp firebaseTimestamp = post['timestamp'];
                    DateTime dateTime = firebaseTimestamp.toDate();

                    // Format waktu sederhana tanpa intl
                    String formattedTime =
                        "${dateTime.day}/${dateTime.month}/${dateTime.year} "
                        "${dateTime.hour}:${dateTime.minute}";

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPost(
                                postId: post.id,
                                title: title,
                                images: images,
                                description: description,
                                timestamp: firebaseTimestamp.toDate(),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thumbnail / Leading
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 10),
                              // Bagian judul, deskripsi, timestamp
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      description.length > 100
                                          ? "${description.substring(0, 100)}..."
                                          : description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formattedTime,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Trailing icon
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
