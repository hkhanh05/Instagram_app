import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<void> followUser(String targetUid) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    await _firestore.collection('follows').add({
      'followerUid': currentUser.uid,
      'followingUid': targetUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> unfollowUser(String targetUid) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final snapshot = await _firestore
        .collection('follows')
        .where('followerUid', isEqualTo: currentUser.uid)
        .where('followingUid', isEqualTo: targetUid)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  static Future<int> getFollowersCount(String uid) async {
    final snapshot = await _firestore
        .collection('follows')
        .where('followingUid', isEqualTo: uid)
        .get();

    return snapshot.docs.length;
  }

  static Future<int> getFollowingCount(String uid) async {
    final snapshot = await _firestore
        .collection('follows')
        .where('followerUid', isEqualTo: uid)
        .get();

    return snapshot.docs.length;
  }
}