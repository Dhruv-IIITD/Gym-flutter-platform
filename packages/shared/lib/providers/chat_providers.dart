import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/message.dart';
import '../repositories/chat_repository.dart';

part 'chat_providers.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) => ChatRepository();

@riverpod
Stream<List<Message>> chatMessages(Ref ref, String chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
}

@riverpod
Stream<List<Message>> recentChats(Ref ref, String userId) {
  return ref.watch(chatRepositoryProvider).watchRecentChats(userId);
}

@riverpod
Stream<int> unreadCount(Ref ref, String userId) {
  return ref.watch(chatRepositoryProvider).watchUnreadCount(userId);
}

@riverpod
class ChatActions extends _$ChatActions {
  @override
  FutureOr<void> build() {}

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    bool isSystemMessage = false,
  }) async {
    final message = Message(
      id: const Uuid().v4(),
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      isSystemMessage: isSystemMessage,
    );
    await ref.watch(chatRepositoryProvider).sendMessage(message);
  }

  Future<void> markAsRead(String messageId) async {
    await ref.watch(chatRepositoryProvider).markAsRead(messageId);
  }
}
