import 'package:flutter/material.dart';

class WtfAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WtfAppBar({
    required this.title,
    required this.badgeLabel,
    this.actions,
    super.key,
  });

  final String title;
  final String badgeLabel;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        ...?actions,
      ],
    );
  }
}
