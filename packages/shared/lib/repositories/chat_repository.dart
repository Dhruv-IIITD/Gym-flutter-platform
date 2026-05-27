import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String getChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Stream<List<Message>> watchRecentChats(String userId) {
    return _firestore
        .collection('messages')
        .where(
          Filter.or(
            Filter('senderId', isEqualTo: userId),
            Filter('receiverId', isEqualTo: userId),
          ),
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final latest = <String, Message>{};
      for (final doc in snapshot.docs) {
        final message = Message.fromFirestore(doc.data(), doc.id);
        latest.putIfAbsent(message.chatId, () => message);
      }
      return latest.values.toList();
    });
  }

  Stream<List<Message>> watchMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> sendMessage(Message message) async {
    await _firestore
        .collection('messages')
        .doc(message.id)
        .set(message.toFirestore());
  }

  Future<void> markAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'status': 'read',
    });
  }

  Future<List<Message>> getMessageHistory(
    String chatId, {
    int limit = 20,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Message.fromFirestore(doc.data(), doc.id))
        .toList()
        .reversed
        .toList();
  }

  Stream<int> watchUnreadCount(String userId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'sent')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
