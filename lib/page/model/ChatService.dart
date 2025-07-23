import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Get all users except current user
  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('user')
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('user').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  // Create or get chat room
  Future<String> createChatRoom(String otherUserId) async {
    List<String> participants = [currentUserId, otherUserId];
    participants.sort();
    
    String chatRoomId = participants.join('_');
    
    DocumentReference chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();
    
    if (!chatRoomSnapshot.exists) {
      await chatRoomRef.set({
        'participants': participants,
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
        'lastMessageSenderId': '',
        'unreadCount': {
          currentUserId: 0,
          otherUserId: 0,
        },
        'createdAt': Timestamp.now(),
      });
    }
    
    return chatRoomId;
  }

  // Get chat rooms for current user
  Stream<List<ChatRoom>> getChatRooms() {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromFirestore(doc))
            .toList());
  }

  // Get messages for a chat room
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  // Send message
  Future<void> sendMessage(String chatRoomId, String receiverId, String message) async {
    try {
      // Add message to subcollection
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'text': message,
        'senderId': currentUserId,
        'receiverId': receiverId,
        'timestamp': Timestamp.now(),
        'isRead': false,
        'messageType': 'text',
      });

      // Update chat room last message
      Map<String, int> unreadCount = {
        currentUserId: 0,
        receiverId: 1, // Increment unread count for receiver
      };

      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': message,
        'lastMessageTime': Timestamp.now(),
        'lastMessageSenderId': currentUserId,
        'unreadCount': unreadCount,
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      // Update unread count
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'unreadCount.$currentUserId': 0,
      });

      // Mark messages as read
      QuerySnapshot unreadMessages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Update user online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      await _firestore.collection('user').doc(currentUserId).update({
        'isOnline': isOnline,
        'lastSeen': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
}