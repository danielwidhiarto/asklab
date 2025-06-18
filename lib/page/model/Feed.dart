import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Feed {
  final String feedId;
  final String title;
  final String description;
  final List<String> images;
  final String userId;
  final DateTime timestamp;
  final String username;
  final String? profilePicture;


  Feed({
    required this.feedId,
    required this.title,
    required this.description,
    required this.images,
    required this.userId,
    required this.timestamp,
    required this.username,
    required this.profilePicture
  });


  factory Feed.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Feed(
      feedId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      username: data['username'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
    );
  }

}

class FeedApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Feed>>  fetchFeeds() async {
    QuerySnapshot snapshot = await _firestore.collection('posts').orderBy('timestamp', descending: true).get();

    List<Feed> feeds = [];

    for (var doc in snapshot.docs){
      final data = doc.data() as Map<String, dynamic>;

      // Ambil data post
      String feedId = doc.id;
      String userId = data['userId'];
      String title = data['title'] ?? '';
      String description = data['description'] ?? '';
      List<String> images = List<String>.from(data['images'] ?? []);
      DateTime timestamp = (data['timestamp'] as Timestamp).toDate();

      // ✅ Ambil data user
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();
      final userData = userSnapshot.data() as Map<String, dynamic>?;

      String username = 'Unknown';
      String? profilePicture;


      debugPrint("user data $userData");

      if(userData != null){
        username = userData['username'] ?? 'Unknown';
        profilePicture = userData['profilePicture'];
      }

      // Tambahkan ke list feeds
      feeds.add(Feed(
        feedId: feedId,
        title: title,
        description: description,
        images: images,
        userId: userId,
        timestamp: timestamp,
        username: username,
        profilePicture: profilePicture,
      ));
    }
    return feeds;
  }
}