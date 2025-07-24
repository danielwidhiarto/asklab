import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UserProfilePage.dart';

class FollowersFollowingPage extends StatefulWidget {
  final String userId;
  final String initialTab; // 'followers' atau 'following'
  final String userName;

  const FollowersFollowingPage({
    Key? key,
    required this.userId,
    required this.initialTab,
    required this.userName,
  }) : super(key: key);

  @override
  _FollowersFollowingPageState createState() => _FollowersFollowingPageState();
}

class _FollowersFollowingPageState extends State<FollowersFollowingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'following' ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}'),
        backgroundColor: const Color(0xFF009ADB),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowersList(),
          _buildFollowingList(),
        ],
      ),
    );
  }

  Widget _buildFollowersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('followers')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No followers yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        var followers = snapshot.data!.docs;
        return ListView.builder(
          itemCount: followers.length,
          itemBuilder: (context, index) {
            String followerId = followers[index].id;
            return _buildUserTile(followerId, 'follower');
          },
        );
      },
    );
  }

  Widget _buildFollowingList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('following')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Not following anyone yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        var following = snapshot.data!.docs;
        return ListView.builder(
          itemCount: following.length,
          itemBuilder: (context, index) {
            String followingId = following[index].id;
            return _buildUserTile(followingId, 'following');
          },
        );
      },
    );
  }

  Widget _buildUserTile(String userId, String type) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String fullName =
            userData['fullName'] ?? userData['username'] ?? 'Unknown User';
        String username = userData['username'] ?? 'username';
        String? profilePicture = userData['profilePicture'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blueAccent,
              backgroundImage:
                  profilePicture != null ? NetworkImage(profilePicture) : null,
              child: profilePicture == null
                  ? const Icon(Icons.account_circle,
                      size: 30, color: Colors.white)
                  : null,
            ),
            title: Text(
              fullName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '@$username',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            trailing: _buildActionButton(userId, type),
            onTap: () {
              // Navigate to user profile page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(userId: userId),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String userId, String type) {
    // Jika ini adalah current user, tidak perlu tombol follow/unfollow
    if (userId == _auth.currentUser?.uid) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('following')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        bool isFollowing = snapshot.hasData && snapshot.data!.exists;

        return ElevatedButton(
          onPressed: () => _toggleFollow(userId, isFollowing),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey : Colors.blueAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 32),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: Text(
            isFollowing ? 'Unfollow' : 'Follow',
            style: const TextStyle(fontSize: 12),
          ),
        );
      },
    );
  }

  Future<void> _toggleFollow(
      String targetUserId, bool isCurrentlyFollowing) async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      if (isCurrentlyFollowing) {
        // Unfollow
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId)
            .delete();

        await _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unfollowed successfully')),
        );
      } else {
        // Follow
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId)
            .set({'timestamp': FieldValue.serverTimestamp()});

        await _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId)
            .set({'timestamp': FieldValue.serverTimestamp()});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Followed successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
