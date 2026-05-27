import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models/user.dart';
import 'package:shared/providers/auth_providers.dart';
import 'package:shared/widgets/chat_list_screen.dart';
import 'package:shared/widgets/conversation_screen.dart';

class TrainerChatListWrapper extends ConsumerWidget {
  const TrainerChatListWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(currentUserProvider).whenOrNull(data: (user) => user) ??
            _fallbackTrainer;
    return ChatListScreen(
      currentUserId: user.id,
      showFab: true,
      fallbackContactId: 'member-dk-demo',
      fallbackContactName: 'DK',
      title: 'Member Chats',
    );
  }
}

class TrainerConversationWrapper extends ConsumerWidget {
  const TrainerConversationWrapper({required this.chatId, super.key});

  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(currentUserProvider).whenOrNull(data: (user) => user) ??
            _fallbackTrainer;
    final receiverId = _otherParticipant(chatId, user.id);
    return ConversationScreen(
      chatId: chatId,
      currentUserId: user.id,
      receiverId: receiverId,
      contactName: receiverId.contains('member') ? 'DK' : 'Member',
    );
  }

  String _otherParticipant(String chatId, String currentUserId) {
    final parts = chatId.split('_');
    if (parts.length != 2) {
      return 'member-dk-demo';
    }
    return parts.first == currentUserId ? parts.last : parts.first;
  }
}

const _fallbackTrainer = User(
  id: 'trainer-aarav-001',
  role: UserRole.trainer,
  name: 'Aarav',
  email: 'aarav@wtfgym.com',
);
