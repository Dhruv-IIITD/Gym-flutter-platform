import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/call_request.dart';
import 'package:shared/models/user.dart';
import 'package:shared/providers/chat_providers.dart';
import 'package:shared/providers/schedule_providers.dart';
import 'package:shared/repositories/chat_repository.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/utils/theme.dart';
import 'package:shared/utils/ui_copy.dart';
import 'package:shared/widgets/empty_state.dart';
import 'package:shared/widgets/shimmer_loading.dart';
import 'package:shared/widgets/status_badge.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(
      callRequestsProvider(seedTrainers.first.id, UserRole.trainer),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Call Requests')),
      body: requests.when(
        data: (items) {
          final pending = items
              .where((request) => request.status == CallRequestStatus.pending)
              .toList();
          if (pending.isEmpty) {
            return const EmptyState(
              icon: Icons.call_missed_outgoing,
              title: 'No pending requests',
            );
          }
          return ListView.separated(
            itemCount: pending.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final request = pending[index];
              return ListTile(
                title: Text(
                  'DK - ${DateFormat.yMMMd().add_jm().format(request.scheduledAt)}',
                ),
                subtitle: Text(request.note.isEmpty ? 'No note' : request.note),
                trailing: Wrap(
                  spacing: WtfSpacing.sm,
                  children: [
                    OutlinedButton(
                      onPressed: () => _decline(context, ref, request),
                      child: const Text('Decline'),
                    ),
                    FilledButton(
                      onPressed: () => _approve(context, ref, request),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const ShimmerList(),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load requests',
          message: error.toString(),
        ),
      ),
    );
  }

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    CallRequest request,
  ) async {
    try {
      final room = await ref
          .read(scheduleActionsProvider.notifier)
          .approveRequest(request);
      final chatId = ChatRepository.getChatId(
        request.memberId,
        request.trainerId,
      );
      await ref.read(chatActionsProvider.notifier).sendMessage(
            chatId: chatId,
            senderId: request.trainerId,
            receiverId: request.memberId,
            text: UiCopy.approved(
              DateFormat.yMMMd().format(request.scheduledAt),
              DateFormat.jm().format(request.scheduledAt),
            ),
            isSystemMessage: true,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request approved')),
        );
        context.go('/call/pre-join/${room.trainerRoomCode}');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  Future<void> _decline(
    BuildContext context,
    WidgetRef ref,
    CallRequest request,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _DeclineReasonDialog(),
    );
    if (reason == null || reason.trim().isEmpty) {
      return;
    }
    await ref.read(scheduleActionsProvider.notifier).declineRequest(
          request,
          reason.trim(),
        );
    final chatId =
        ChatRepository.getChatId(request.memberId, request.trainerId);
    await ref.read(chatActionsProvider.notifier).sendMessage(
          chatId: chatId,
          senderId: request.trainerId,
          receiverId: request.memberId,
          text: UiCopy.declined(reason.trim()),
          isSystemMessage: true,
        );
  }
}

class _DeclineReasonDialog extends StatefulWidget {
  const _DeclineReasonDialog();

  @override
  State<_DeclineReasonDialog> createState() => _DeclineReasonDialogState();
}

class _DeclineReasonDialogState extends State<_DeclineReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Decline Request'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Reason'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Decline'),
        ),
      ],
    );
  }
}

class ApprovedRequestsScreen extends ConsumerWidget {
  const ApprovedRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(
      callRequestsProvider(seedTrainers.first.id, UserRole.trainer),
    );
    return requests.when(
      data: (items) => ListView(
        children: [
          for (final request in items)
            ListTile(
              title:
                  Text(DateFormat.yMMMd().add_jm().format(request.scheduledAt)),
              trailing: StatusBadge(status: request.status),
            ),
        ],
      ),
      loading: () => const ShimmerList(),
      error: (error, _) => Text(error.toString()),
    );
  }
}
