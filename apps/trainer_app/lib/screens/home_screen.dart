import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/utils/theme.dart';
import 'package:shared/widgets/dev_panel.dart';
import 'package:shared/widgets/wtf_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WtfAppBar(title: 'WTF Trainer', badgeLabel: 'Aarav'),
      body: Stack(
        children: [
          GridView.count(
            padding: const EdgeInsets.all(WtfSpacing.md),
            crossAxisCount: 2,
            mainAxisSpacing: WtfSpacing.md,
            crossAxisSpacing: WtfSpacing.md,
            childAspectRatio: 1,
            children: [
              _Tile(
                icon: Icons.group_outlined,
                title: 'Members',
                subtitle: 'View your clients',
                onTap: () => context.go('/members'),
              ),
              _Tile(
                icon: Icons.chat_bubble_outline,
                title: 'Chats',
                subtitle: 'Message members',
                onTap: () => context.go('/chat'),
              ),
              _Tile(
                icon: Icons.call_outlined,
                title: 'Requests',
                subtitle: 'Call requests',
                onTap: () => context.go('/requests'),
              ),
              _Tile(
                icon: Icons.assignment_outlined,
                title: 'Sessions',
                subtitle: 'Session history',
                onTap: () => context.go('/sessions'),
              ),
            ],
          ),
          const DevPanel(),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(WtfSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: WtfColors.trainerPrimaryLight,
                foregroundColor: WtfColors.trainerPrimary,
                child: Icon(icon),
              ),
              const SizedBox(height: WtfSpacing.md),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: WtfColors.neutral600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
