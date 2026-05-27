import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models/user.dart';
import 'package:shared/providers/auth_providers.dart';
import 'package:shared/repositories/chat_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/widgets/chat_list_screen.dart';
import 'package:shared/widgets/conversation_screen.dart';

class GuruChatListWrapper extends ConsumerWidget {
  const GuruChatListWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(currentUserProvider).whenOrNull(data: (user) => user) ??
            _fallbackUser;
    return ChatListScreen(
      currentUserId: user.id,
      fallbackContactId: user.assignedTrainerId ?? seedTrainers.first.id,
      fallbackContactName: 'Aarav',
      title: 'Trainer Chat',
    );
  }
}

class GuruConversationWrapper extends ConsumerWidget {
  const GuruConversationWrapper({required this.chatId, super.key});

  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(currentUserProvider).whenOrNull(data: (user) => user) ??
            _fallbackUser;
    final receiverId = _otherParticipant(chatId, user.id);
    return ConversationScreen(
      chatId: chatId,
      currentUserId: user.id,
      receiverId: receiverId,
      contactName: _displayName(receiverId),
    );
  }

  String _otherParticipant(String chatId, String currentUserId) {
    final parts = chatId.split('_');
    if (parts.length != 2) {
      return seedTrainers.first.id;
    }
    return parts.first == currentUserId ? parts.last : parts.first;
  }

  String _displayName(String id) {
    if (id.contains('aarav')) {
      return 'Aarav';
    }
    if (id.contains('priya')) {
      return 'Priya';
    }
    if (id.contains('rahul')) {
      return 'Rahul';
    }
    return 'Trainer';
  }
}

final _fallbackUser = User(
  id: 'member-dk-demo',
  role: UserRole.member,
  name: 'DK',
  email: 'dk@example.com',
  assignedTrainerId: seedTrainers.first.id,
);

String guruDefaultChatId(String memberId, String trainerId) {
  return ChatRepository.getChatId(memberId, trainerId);
}
