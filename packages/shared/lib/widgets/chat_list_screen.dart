import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/message.dart';
import '../providers/chat_providers.dart';
import '../utils/theme.dart';
import '../utils/ui_copy.dart';
import 'empty_state.dart';
import 'shimmer_loading.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({
    required this.currentUserId,
    this.showFab = false,
    this.fallbackContactId = 'trainer-aarav-001',
    this.fallbackContactName = 'Aarav',
    this.title = 'Chats',
    super.key,
  });

  final String currentUserId;
  final bool showFab;
  final String fallbackContactId;
  final String fallbackContactName;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(recentChatsProvider(currentUserId));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: showFab
          ? FloatingActionButton(
              tooltip: 'New chat',
              onPressed: () {
                final chatId = _chatId(currentUserId, fallbackContactId);
                context.go('/chat/$chatId');
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: chats.when(
        data: (messages) {
          if (messages.isEmpty) {
            return EmptyState(
              icon: Icons.mark_chat_unread_outlined,
              title: UiCopy.emptyChat,
              actionLabel: UiCopy.emptyChatCta,
              onAction: () => context.go(
                '/chat/${_chatId(currentUserId, fallbackContactId)}',
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: WtfSpacing.sm),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final message = messages[index];
              final peerId = message.senderId == currentUserId
                  ? message.receiverId
                  : message.senderId;
              final isUnread = message.receiverId == currentUserId &&
                  message.status == MessageStatus.sent;
              return ListTile(
                leading: CircleAvatar(
                  child: Text(_initials(_displayName(peerId))),
                ),
                title: Text(_displayName(peerId)),
                subtitle: Text(
                  message.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _relativeTime(message.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: isUnread ? 1 : 0,
                      child: const _UnreadDot(),
                    ),
                  ],
                ),
                onTap: () => context.go('/chat/${message.chatId}'),
              );
            },
          );
        },
        loading: () => const ShimmerList(),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load chats',
          message: error.toString(),
        ),
      ),
    );
  }

  static String _chatId(String left, String right) {
    final sorted = [left, right]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  static String _displayName(String peerId) {
    if (peerId.contains('aarav')) {
      return 'Aarav';
    }
    if (peerId.contains('priya')) {
      return 'Priya';
    }
    if (peerId.contains('rahul')) {
      return 'Rahul';
    }
    if (peerId.contains('member') || peerId.contains('dk')) {
      return 'DK';
    }
    return peerId.split('-').first;
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  static String _relativeTime(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) {
      return 'now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    }
    return DateFormat.MMMd().format(value);
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: WtfColors.error,
      ),
      child: const Text(
        '1',
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}
