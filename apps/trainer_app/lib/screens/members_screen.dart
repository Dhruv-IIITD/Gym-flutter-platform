import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/models/user.dart';
import 'package:shared/providers/session_providers.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/utils/theme.dart';
import 'package:shared/widgets/empty_state.dart';
import 'package:shared/widgets/shimmer_loading.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(membersProvider(seedTrainers.first.id));
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: members.when(
        data: (items) {
          final rows = items.isEmpty ? [_demoMember] : items;
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final member = rows[index];
              return ListTile(
                leading: CircleAvatar(child: Text(member.name[0])),
                title: Text(member.name),
                subtitle: Text(member.email),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/members/${member.id}'),
              );
            },
          );
        },
        loading: () => const ShimmerList(),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load members',
          message: error.toString(),
        ),
      ),
    );
  }
}

class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({required this.memberId, super.key});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Detail')),
      body: ListView(
        padding: const EdgeInsets.all(WtfSpacing.md),
        children: [
          const CircleAvatar(radius: 36, child: Text('DK')),
          const SizedBox(height: WtfSpacing.md),
          Text(
            'DK',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: WtfSpacing.sm),
          Text(
            'Assigned member - $memberId',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: WtfColors.neutral600,
                ),
          ),
          const SizedBox(height: WtfSpacing.lg),
          FilledButton.icon(
            onPressed: () => context.go('/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Open Chat'),
          ),
        ],
      ),
    );
  }
}

const _demoMember = User(
  id: 'member-dk-demo',
  role: UserRole.member,
  name: 'DK',
  email: 'dk@example.com',
  assignedTrainerId: 'trainer-aarav-001',
);
