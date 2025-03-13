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
      // 🔻 Unfollow
      await userRef.collection('followers').doc(currentUser.uid).delete();
      await currentUserRef.collection('following').doc(widget.userId).delete();
      setState(() => isFollowing = false);
    } else {
      // 🔺 Follow
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
    // Navigasi ke chat (sesuai kebutuhan)
    print("Navigating to chat with ${widget.userId}");
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

            // Avatar
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

            // Fullname & Username
            if (fullName != null)
              Text(
                fullName!,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            Text(
              '@${username ?? "username"}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 15),

            // Statistik (Posts, Followers, Following)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Post count
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
                  // Followers count
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
                  // Following count
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

            // Follow & Message Button (hanya jika bukan profile sendiri)
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
                        child: Text(
                          isFollowing ? "Unfollow" : "Follow",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.message, size: 20),
                        label: const Text(
                          "Message",
                          style: TextStyle(fontSize: 16),
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

            // List of posts in a 'forum-like' style
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .where('userId', isEqualTo: widget.userId)
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
                    Timestamp timestamp = post['timestamp'];
                    DateTime dateTime = timestamp.toDate();

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
                        onTap: () => _navigateToPostDetail(post),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Thumbnail
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
                              // Judul, deskripsi, timestamp
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

  // Widget info stat
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
}
