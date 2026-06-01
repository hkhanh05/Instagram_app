import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_model.dart';

class ChatService {
  ChatService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chatsRef =>
      _db.collection('chats');

  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _chatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final chatRef = _chatsRef.doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    final batch = _db.batch();

    batch.set(messageRef, {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.set(
      chatRef,
      {
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': text,
        'lastSenderId': senderId,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}