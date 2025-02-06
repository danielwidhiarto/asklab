import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'DetailPost.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? fullName;
  String? username;
  String? bio;
  String? profilePicture;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkIfFollowing();
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(widget.userId).get();
    if (userDoc.exists) {
      setState(() {
        fullName = userDoc['fullName'];
        username = userDoc['username'];
        bio = userDoc['bio'];
        profilePicture = userDoc['profilePicture'];
      });
    }
  }

  Future<void> _checkIfFollowing() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(widget.userId)
        .collection('followers')
        .doc(currentUser.uid)
        .get();

    setState(() {
      isFollowing = doc.exists;
    });
  }

  Future<void> _toggleFollow() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    DocumentReference userRef =
        _firestore.collection('users').doc(widget.userId);
    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUser.uid);

    if (isFollowing) {
      // 🔻 Unfollow: Hapus dari Firestore
      await userRef.collection('followers').doc(currentUser.uid).delete();
      await currentUserRef.collection('following').doc(widget.userId).delete();
      setState(() => isFollowing = false);
    } else {
      // 🔺 Follow: Tambahkan data ke Firestore
      await userRef.collection('followers').doc(currentUser.uid).set({
        "userId": currentUser.uid,
        "followedAt": FieldValue.serverTimestamp(),
      });

      await currentUserRef.collection('following').doc(widget.userId).set({
        "userId": widget.userId,
        "followedAt": FieldValue.serverTimestamp(),
      });

      setState(() => isFollowing = true);
    }
  }

  void _sendMessage() {
    print("Navigating to chat with ${widget.userId}");
  }

  void _navigateToPostDetail(DocumentSnapshot post) {
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
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;
    bool isOwnProfile = currentUser != null && currentUser.uid == widget.userId;

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

            // Statistik User (Menggunakan StreamBuilder agar Real-time)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('posts')
                        .where('userId', isEqualTo: widget.userId)
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
                        .doc(widget.userId)
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
                        .doc(widget.userId)
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

            // Tombol Follow/Unfollow & Message
            if (!isOwnProfile)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing
                              ? Colors.grey[400]
                              : Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(isFollowing ? "Unfollow" : "Follow",
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.message, size: 20),
                        label: const Text("Message",
                            style: TextStyle(fontSize: 16)),
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
