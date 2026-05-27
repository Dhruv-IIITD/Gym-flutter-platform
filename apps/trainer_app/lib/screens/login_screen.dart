import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/models/user.dart';
import 'package:shared/providers/auth_providers.dart';
import 'package:shared/services/auth_service.dart';
import 'package:shared/utils/theme.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(WtfSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'WTF',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: WtfColors.trainerPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: WtfSpacing.sm),
              Text(
                'Trainer Portal',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: WtfSpacing.xl),
              FilledButton(
                onPressed: () async {
                  await ref.read(authServiceProvider).seedTrainersIfNeeded();
                  await ref.read(currentUserProvider.notifier).login(
                        'Aarav',
                        'aarav@wtfgym.com',
                        UserRole.trainer,
                        id: seedTrainers.first.id,
                      );
                  if (context.mounted) {
                    context.go('/');
                  }
                },
                child: const Text('Login as Aarav'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
