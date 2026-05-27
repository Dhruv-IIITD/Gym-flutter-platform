import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared/models/call_request.dart';
import 'package:shared/models/user.dart';
import 'package:shared/providers/auth_providers.dart';
import 'package:shared/providers/schedule_providers.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/utils/constants.dart';
import 'package:shared/utils/theme.dart';
import 'package:shared/utils/ui_copy.dart';
import 'package:shared/utils/validators.dart';
import 'package:shared/widgets/empty_state.dart';
import 'package:shared/widgets/shimmer_loading.dart';
import 'package:shared/widgets/status_badge.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late DateTime _selectedDate;
  DateTime? _selectedSlot;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDate = DateTime(today.year, today.month, today.day);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user =
        ref.watch(currentUserProvider).whenOrNull(data: (user) => user) ??
            _fallbackUser;
    final dates = ref.watch(availableDatesProvider);
    final slots = ref.watch(availableSlotsProvider(_selectedDate));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Call'),
        actions: [
          TextButton(
            onPressed: () => context.go('/requests'),
            child: const Text('My Requests'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(WtfSpacing.md),
        children: [
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: WtfSpacing.sm),
              itemBuilder: (context, index) {
                final date = dates[index];
                final selected = _sameDay(date, _selectedDate);
                return ChoiceChip(
                  selected: selected,
                  label: SizedBox(
                    width: 84,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat.E().format(date)),
                        Text(DateFormat.MMMd().format(date)),
                      ],
                    ),
                  ),
                  onSelected: (_) => setState(() {
                    _selectedDate = date;
                    _selectedSlot = null;
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: WtfSpacing.md),
          Wrap(
            spacing: WtfSpacing.sm,
            runSpacing: WtfSpacing.sm,
            children: [
              for (final slot in slots)
                ChoiceChip(
                  selected: _selectedSlot == slot,
                  label: Text(DateFormat.jm().format(slot)),
                  onSelected: slot.isBefore(DateTime.now())
                      ? null
                      : (_) => setState(() => _selectedSlot = slot),
                ),
            ],
          ),
          const SizedBox(height: WtfSpacing.md),
          TextField(
            controller: _noteController,
            maxLength: AppConstants.maxNoteLength,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: WtfSpacing.md),
          FilledButton(
            onPressed: () => _requestCall(user),
            child: const Text('Request Call'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestCall(User user) async {
    final slot = _selectedSlot;
    if (slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a time slot')),
      );
      return;
    }
    final timeError = Validators.validateScheduleTime(slot);
    final noteError = Validators.validateNote(_noteController.text);
    if (timeError != null || noteError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(timeError ?? noteError!)),
      );
      return;
    }
    final trainerId = user.assignedTrainerId ?? seedTrainers.first.id;
    await ref.read(scheduleActionsProvider.notifier).createRequest(
          memberId: user.id,
          trainerId: trainerId,
          scheduledAt: slot,
          note: _noteController.text.trim(),
        );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(UiCopy.requestSent)),
    );
    context.go('/requests');
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(currentUserProvider).whenOrNull(data: (user) => user) ??
            _fallbackUser;
    final requests = ref.watch(callRequestsProvider(user.id, UserRole.member));
    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: requests.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'No call requests',
              actionLabel: 'Schedule',
              onAction: () => context.go('/schedule'),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final request = items[index];
              final canJoin =
                  ref.read(scheduleServiceProvider).canJoin(request);
              return ListTile(
                title: Text(
                    DateFormat.yMMMd().add_jm().format(request.scheduledAt)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (request.note.isNotEmpty) Text(request.note),
                    if (request.status == CallRequestStatus.declined &&
                        request.declineReason != null)
                      Text('Reason: ${request.declineReason}'),
                  ],
                ),
                trailing: Wrap(
                  spacing: WtfSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusBadge(status: request.status),
                    if (canJoin)
                      FilledButton(
                        onPressed: () => context.go(
                          '/call/pre-join/${request.roomMetaId ?? 'member-room-code'}',
                        ),
                        child: const Text('Join'),
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
}

final _fallbackUser = User(
  id: 'member-dk-demo',
  role: UserRole.member,
  name: 'DK',
  email: 'dk@example.com',
  assignedTrainerId: seedTrainers.first.id,
);
