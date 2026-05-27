import 'package:flutter/material.dart';

import '../models/call_request.dart';
import '../utils/theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final CallRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CallRequestStatus.pending => ('Pending', WtfColors.warning),
      CallRequestStatus.approved => ('Approved', WtfColors.success),
      CallRequestStatus.declined => ('Declined', WtfColors.error),
      CallRequestStatus.completed => ('Completed', WtfColors.neutral600),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
