import 'package:cloud_firestore/cloud_firestore.dart';

class SearchApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> search(String type, String query) async {
    if(query.isEmpty){
      return [];
    }

    QuerySnapshot snapshot;

    if (type == 'Posts') {
      snapshot = await _firestore
          .collection('posts')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
    } else {
      snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
    }

    return snapshot.docs;
  }
}