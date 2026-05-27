import 'dart:async';

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
    final messages = _firestore.collection('messages');
    return _watchMergedMessages([
      messages.where('senderId', isEqualTo: userId),
      messages.where('receiverId', isEqualTo: userId),
    ]).map((messages) {
      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latest = <String, Message>{};
      for (final message in messages) {
        latest.putIfAbsent(message.chatId, () => message);
      }
      return latest.values.toList();
    });
  }

  Stream<List<Message>> watchMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => Message.fromFirestore(doc.data(), doc.id))
          .toList();
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return messages;
    });
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
  }) async {
    final query = _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .limit(limit);

    final snapshot = await query.get();
    final messages = snapshot.docs
        .map((doc) => Message.fromFirestore(doc.data(), doc.id))
        .toList();
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  Stream<int> watchUnreadCount(String userId) {
    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc.data(), doc.id))
            .where((message) => message.status == MessageStatus.sent)
            .length);
  }

  Stream<List<Message>> _watchMergedMessages(
    List<Query<Map<String, dynamic>>> queries,
  ) {
    late final StreamController<List<Message>> controller;
    final latestByQuery = <int, List<Message>>{};
    final subscriptions =
        <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];

    void emit() {
      final byId = <String, Message>{};
      for (final messages in latestByQuery.values) {
        for (final message in messages) {
          byId[message.id] = message;
        }
      }
      controller.add(byId.values.toList());
    }

    controller = StreamController<List<Message>>(
      onListen: () {
        for (var index = 0; index < queries.length; index++) {
          subscriptions.add(
            queries[index].snapshots().listen(
              (snapshot) {
                latestByQuery[index] = snapshot.docs
                    .map((doc) => Message.fromFirestore(doc.data(), doc.id))
                    .toList();
                emit();
              },
              onError: controller.addError,
            ),
          );
        }
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }
}
