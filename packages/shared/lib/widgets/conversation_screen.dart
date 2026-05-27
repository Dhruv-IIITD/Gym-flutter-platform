import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/message.dart';
import '../providers/chat_providers.dart';
import '../utils/theme.dart';
import 'empty_state.dart';
import 'shimmer_loading.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({
    required this.chatId,
    required this.currentUserId,
    required this.receiverId,
    required this.contactName,
    this.roomCode,
    super.key,
  });

  final String chatId;
  final String currentUserId;
  final String receiverId;
  final String contactName;
  final String? roomCode;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _showTyping = false;
  bool _showJumpToBottom = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final shouldShow = _scrollController.hasClients &&
          _scrollController.offset <
              _scrollController.position.maxScrollExtent - 240;
      if (shouldShow != _showJumpToBottom) {
        setState(() => _showJumpToBottom = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.chatId));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
        actions: [
          if (widget.roomCode != null)
            IconButton(
              tooltip: 'Join call',
              onPressed: () => context.go('/call/pre-join/${widget.roomCode}'),
              icon: const Icon(Icons.videocam_outlined),
            ),
        ],
      ),
      floatingActionButton: _showJumpToBottom
          ? FloatingActionButton.small(
              tooltip: 'Jump to latest',
              onPressed: _scrollToBottom,
              child: const Icon(Icons.keyboard_arrow_down),
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (items) {
                _markVisibleMessagesAsRead(items);
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No messages yet',
                    actionLabel: 'Say hi',
                    onAction: () {
                      _controller.text = 'Hi Coach';
                      _send();
                    },
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_showJumpToBottom) {
                    _scrollToBottom();
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(WtfSpacing.md),
                  itemCount: items.length + (_showTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_showTyping && index == items.length) {
                      return const _TypingIndicator();
                    }
                    return _MessageBubble(
                      message: items[index],
                      isMine: items[index].senderId == widget.currentUserId,
                    );
                  },
                );
              },
              loading: () => const ShimmerList(),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load messages',
                message: error.toString(),
              ),
            ),
          ),
          _Composer(
            controller: _controller,
            onSend: _send,
            onQuickReply: (value) => setState(() => _controller.text = value),
          ),
        ],
      ),
    );
  }

  void _markVisibleMessagesAsRead(List<Message> messages) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final actions = ref.read(chatActionsProvider.notifier);
      for (final message in messages) {
        if (message.receiverId == widget.currentUserId &&
            message.status == MessageStatus.sent) {
          unawaited(actions.markAsRead(message.id));
        }
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    _controller.clear();
    await ref.read(chatActionsProvider.notifier).sendMessage(
          chatId: widget.chatId,
          senderId: widget.currentUserId,
          receiverId: widget.receiverId,
          text: text,
        );
    setState(() => _showTyping = true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _showTyping = false);
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    if (message.isSystemMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: WtfSpacing.sm),
        child: Text(
          message.text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: WtfColors.neutral600,
                fontStyle: FontStyle.italic,
              ),
        ),
      );
    }
    final primary = Theme.of(context).colorScheme.primary;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 20, end: 0),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        builder: (context, offset, child) => Transform.translate(
          offset: Offset(isMine ? offset : -offset, 0),
          child: child,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Container(
            margin: const EdgeInsets.only(bottom: WtfSpacing.sm),
            padding: const EdgeInsets.all(WtfSpacing.md),
            decoration: BoxDecoration(
              color: isMine ? primary : Colors.white,
              border: Border.all(
                color: isMine ? primary : WtfColors.neutral200,
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isMine ? 12 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 12),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMine ? Colors.white : WtfColors.neutral900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat.jm().format(message.createdAt)} ${_ticks()}',
                  style: TextStyle(
                    color: isMine
                        ? Colors.white.withValues(alpha: 0.78)
                        : WtfColors.neutral600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _ticks() {
    if (!isMine) {
      return '';
    }
    return message.status == MessageStatus.read ? 'read' : 'sent';
  }
}

class _Composer extends StatefulWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onQuickReply,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String> onQuickReply;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: WtfColors.neutral200)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final reply in const [
                  'Got it',
                  'Can we talk at 6?',
                  'Share plan?',
                ])
                  ActionChip(
                    label: Text(reply),
                    onPressed: () => widget.onQuickReply(reply),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    maxLines: 3,
                    minLines: 1,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Send',
                  onPressed: widget.controller.text.trim().isEmpty
                      ? null
                      : widget.onSend,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: WtfColors.neutral200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final value = (_controller.value + index * 0.2) % 1;
                return Transform.translate(
                  offset: Offset(0, -4 * value),
                  child: child,
                );
              },
              child: Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: WtfColors.neutral600,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
