import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/models/user.dart';
import 'package:shared/providers/auth_providers.dart';
import 'package:shared/widgets/sessions_list_screen.dart';

class GuruSessionsWrapper extends ConsumerWidget {
  const GuruSessionsWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(currentUserProvider).whenOrNull(data: (user) => user);
    return SessionsListScreen(
      userId: user?.id ?? 'member-dk-demo',
      role: UserRole.member,
    );
  }
}
