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
      appBar: const WtfAppBar(title: 'WTF Guru', badgeLabel: 'DK'),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(WtfSpacing.md),
            children: [
              _HomeCard(
                icon: Icons.chat_bubble_outline,
                title: 'Chat',
                subtitle: 'Message your trainer',
                onTap: () => context.go('/chat'),
              ),
              _HomeCard(
                icon: Icons.calendar_month_outlined,
                title: 'Schedule Call',
                subtitle: 'Book a video session',
                onTap: () => context.go('/schedule'),
              ),
              _HomeCard(
                icon: Icons.assignment_outlined,
                title: 'Session Logs',
                subtitle: 'View past sessions',
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

class _HomeCard extends StatelessWidget {
  const _HomeCard({
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
      margin: const EdgeInsets.only(bottom: WtfSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(WtfSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: WtfColors.guruPrimaryLight,
                foregroundColor: WtfColors.guruPrimary,
                child: Icon(icon),
              ),
              const SizedBox(width: WtfSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: WtfColors.neutral600,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
