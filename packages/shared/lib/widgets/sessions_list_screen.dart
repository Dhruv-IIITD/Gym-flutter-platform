import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/session_log.dart';
import '../models/user.dart';
import '../providers/session_providers.dart';
import '../utils/theme.dart';
import '../utils/ui_copy.dart';
import 'empty_state.dart';
import 'rating_stars.dart';
import 'shimmer_loading.dart';

enum SessionFilter { all, last7Days, thisMonth }

class SessionsListScreen extends ConsumerStatefulWidget {
  const SessionsListScreen({
    required this.userId,
    required this.role,
    super.key,
  });

  final String userId;
  final UserRole role;

  @override
  ConsumerState<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends ConsumerState<SessionsListScreen> {
  SessionFilter _filter = SessionFilter.all;

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(sessionLogsProvider(widget.userId, widget.role));
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(WtfSpacing.md),
            child: Wrap(
              spacing: WtfSpacing.sm,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == SessionFilter.all,
                  onSelected: () => setState(() => _filter = SessionFilter.all),
                ),
                _FilterChip(
                  label: 'Last 7 Days',
                  selected: _filter == SessionFilter.last7Days,
                  onSelected: () =>
                      setState(() => _filter = SessionFilter.last7Days),
                ),
                _FilterChip(
                  label: 'This Month',
                  selected: _filter == SessionFilter.thisMonth,
                  onSelected: () =>
                      setState(() => _filter = SessionFilter.thisMonth),
                ),
              ],
            ),
          ),
          Expanded(
            child: logs.when(
              data: (items) {
                final filtered = _applyFilter(items);
                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_available_outlined,
                    title: UiCopy.noSessions,
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = filtered[index];
                    return ListTile(
                      title: Text(
                          DateFormat.yMMMd().add_jm().format(log.startedAt)),
                      subtitle: Text(_durationLabel(log.durationSec)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RatingStars(rating: log.rating, size: 18),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () => _showDetail(context, log),
                    );
                  },
                );
              },
              loading: () => const ShimmerList(),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load sessions',
                message: error.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SessionLog> _applyFilter(List<SessionLog> logs) {
    final now = DateTime.now();
    return switch (_filter) {
      SessionFilter.all => logs,
      SessionFilter.last7Days => logs
          .where((log) =>
              log.startedAt.isAfter(now.subtract(const Duration(days: 7))))
          .toList(),
      SessionFilter.thisMonth => logs
          .where(
            (log) =>
                log.startedAt.year == now.year &&
                log.startedAt.month == now.month,
          )
          .toList(),
    };
  }

  void _showDetail(BuildContext context, SessionLog log) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(WtfSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session Details',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: WtfSpacing.md),
            Text(DateFormat.yMMMMd().add_jm().format(log.startedAt)),
            const SizedBox(height: WtfSpacing.sm),
            Text(_durationLabel(log.durationSec)),
            const SizedBox(height: WtfSpacing.md),
            RatingStars(rating: log.rating, size: 20),
            const Divider(height: 32),
            Text('Trainer notes: ${log.trainerNotes ?? 'None'}'),
            const SizedBox(height: WtfSpacing.sm),
            Text('Member notes: ${log.memberNotes ?? 'None'}'),
          ],
        ),
      ),
    );
  }

  String _durationLabel(int? seconds) {
    if (seconds == null) {
      return 'Duration not captured';
    }
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes}m ${remainder}s';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
